+++
title = "Terraform Data Blocks: Surgeon General's Warning"
tags = []
date = "2022-04-24"
+++

##### Spicy Peppers Rating System | 🌶 - One Pepper | Bold and Zesty; Potentially Misinformation

{{< rawhtml >}}

<div style="border: solid black 4px; max-width: 850px; padding: 10px 15px; background: white; color: black; font-size: 1.5em; line-height: 1.2em; text-align: center; margin-top: 25px">
SURGEON GENERAL'S WARNING: Quitting <span style="color: #111; font-family: serif; font-weight: bold; font-style: italic">DATA BLOCKS</span> Now Greatly Reduces Serious Risks to Your <span style="color: #111; font-family: serif; font-weight: bold; font-style: italic">TERRAFORM INFRASTRUCTURE</span>.
</div>

{{< /rawhtml >}}

### Summary

Data blocks (Terraform Data sources) appear harmless, but aren't. This is because every resource that relies on a data block is in danger of being replaced, because in some circumstances, data blocks are evaluated **after apply**. It's just a matter of time.

I know the summary above didn't make sense, so read on.

### Data blocks explained

Data blocks, or [data sources](https://www.terraform.io/language/data-sources) in Hashicorp's parlance, are a convenient way to get at information. As a wise man once told me, data blocks are basically API calls (that retrieve data). I'll refer to data sources as data blocks because in the code they are a `data {}` block.

If you're entirely unfamiliar with them, Hashicorp docs provide a [a good overview](https://www.terraform.io/language/data-sources).

As I've discovered, data blocks are convenient right up until Terraform wants to replace **the entire Kubernetes cluster**. Did I mention it was **the entire Kubernetes cluster**? Not just a node pool, no, **the entire Kubernetes cluster**. And as bad as that sounds, it was worse, actually--yes, it was **the entire Kubernetes cluster**, but it was most everything else, too.

### The danger, by example

[This remarkably friendly GitHub issue](https://github.com/hashicorp/terraform/issues/28377) details the danger better than I can, but I'll try anyway, with the minimum possible example. An MVP of failure, if you will.

In this example, we have two things:

- not managed by terraform: a subnet `subnet1`
- managed by terraform: a network interface (think NIC, but in the cloud) which lives on the subnet

#### The Beginning: No Data Blocks, No Problems

In the beginning, we'll start with no frills and no data blocks.

```hcl
######################################
## The Beginning: No Data Blocks
######################################

# subnet already exists, not managed by terraform

resource "azurerm_network_interface" "example" {
  # note it's a hardcoded string - a potential DRY violation! Call the cops
  subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/examplerg/providers/Microsoft.Network/virtualNetworks/examplevnet/subnets/subnet1"

  # ... (details omitted)
}
```

This works great! To specify which subnet to place the `azurerm_network_interface` in, we've hardcoded the `subnet_id`. This works, it's safe, and any potential mistakes can be discovered during a `terraform plan` ... but it's ugly? It's hard to read?

So here's what we did next, for a little bit of convenience. Let's call this scenario Trouble Ahead: Storm's A-brewin'.

#### Trouble Ahead: Data Block Introduced

```hcl
######################################
## Trouble Ahead: Data Block Introduced For Convenience
######################################

# subnet already exists - thus we reference it as a 'data' block
data "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
}

resource "azurerm_network_interface" "example" {
  # note subnet_id is bound to a data block
  subnet_id      = data.azurerm_subnet.example.id

  # ... (details omitted)
}
```

While this works perfectly on the initial `terraform apply`, we are now in potential future danger of replacing our `azurerm_network_interface` resource.

The danger is not immediate--so far, we're still safe. To fall fully into the trap, we need to do a few specific things:

- Use a data block in a module
- Use outputs from that module
- Explicitly `depends_on` that module

And let me be clear that because none of us knew, we built our terraform in such a way that **the majority of our infrastructure** was affected by such an issue. It's not that difficult to do. Use data blocks freely and introduce modules as your terraform grows. In just a short time, you'll be in trouble, just like me!

Let's see what such a disaster looks like:

```hcl
######################################
## Imminent Doom: Data Block + Module + depends_on
######################################

# ~~~~~~ vnet module.tf ~~~~~~
data "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
}


# ~~~~~~    main.tf     ~~~~~~
module "vnet" {
  # ... (details omitted)
}

resource "azurerm_network_interface" "example" {
  # note subnet_id is bound to a data block, by way of the vnet module
  subnet_id      = module.vnet.subnet1.id

  depends_on = [module.vnet]
}
```

Harmless, right? Let's look at what `terraform plan` tells us now:

```hcl
# (the following is a partial `terraform plan` output)

# resource.azurerm_network_interface.example must be replaced
-/+ resource "azurerm_network_interface" "example" {
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/examplerg/providers/Microsoft.Network/virtualNetworks/examplevnet/subnets/subnet1" -> (known after apply) # forces replacement

  # ... (omitted)
}
```

Congratulations, we're about to **replace all our infrastructure**!

#### Explanation

So let's walk through what happened, to the best of my understanding.

1. We have resources in terraform.
1. Those resources rely directly or indirectly on data blocks.
1. The data blocks are in a module, and we explicitly `depends_on` that module.
1. Presumably (speculating), terraform can't know the value of the output of the module until during apply of the module, and because of this, it doesn't know if values will change.
1. Therefore, it chooses the only predictable choice, and assumes that yes, the value will change.
1. And if this forces replacement of an entire resource, well, so be it.
1. Anyway a big chunk of our infrastructure is now cursed by the dreaded `-> (known after apply) # forces replacement` message.
1. And though I haven't tested it, according to the GitHub Issue at https://github.com/hashicorp/terraform/issues/28377 - terraform is **not bluffing** and will indeed destroy and replace our resources.

Let me attempt to explain this in a different way:

1. SCENE: Cozy study. A leather chair sits next to the fireplace. Camera pans to the fireplace. A gun sits on the mantle. End Scene.
1. Time passes.
1. SCENE: Enters cozy study with a coworker. Loud and angry argument about whether 'gitops is worth it'. Stands by the fireplace. Picks up the gun, toggles the safety off, uses this as a metaphor for the relative safety of the additional gates/checks. Puts the gun back. End Scene.
1. A great deal of time passes. Adventures!
1. More adventures! More time passes!
1. SCENE: "...and so terraform apply works like this gun. Running `terraform apply` cocks the gun" ... (proceeds to cock the gun) ... but nothing happens until you pull the trigger! See? It's totally safe." (puts the gun back on the mantle) "No worries, the gun's not loaded." (walks away) Camera pans to gun, lingers on it for a few seconds. End Scene.
1. (much later) SCENE: Wildly gesticulating "looK aT Me, i'M A FreeBSD AdMINiSTraTor!" Picks up the gun, continues flailing wildly. "I uSE pOrts aND jailS" Gesticulates even more furiously. "AnD ALSo OBsCUre FIleSYStEms!" Impassioned gesticulation crescendoes with a complete loss of control. Drops gun, which hits the floor. Gun fires.
1. Friend, we've just shot ourselves in the foot. I can't believe it either, but here we are.

In this colorful allegory, data blocks are the gun. And my point here is, while we see data blocks as harmless conveniences, we should treat them instead as a potentially loaded gun, which may fire at any moment.

There are two succinct, authoritative answers on the GitHub Issue thread explaining what's happening, though to their detriment they do _not_ fire any guns or reference a three-act structure in their explanations:

- [First explanation](https://github.com/hashicorp/terraform/issues/28377#issuecomment-820398608)
- [Second explanation](https://github.com/hashicorp/terraform/issues/28377#issuecomment-824070018)

#### Solution

One solution is to stop using data blocks. Here's the fixed example:

```hcl
######################################
## The Path of Enlightenment: Not Relying On Data Blocks
######################################

# subnet already exists, not managed by terraform

resource "azurerm_network_interface" "example" {
  # note it's a hardcoded string - what beautiful simplicity!
  subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/examplerg/providers/Microsoft.Network/virtualNetworks/examplevnet/subnets/subnet1"

  # ... (details omitted)
}
```

Before enlightenment: chop wood, carry water. After enlightenment: chop wood, carry water.

And while I've hardcoded the `subnet_id` in the enlightened example above, I would (and certainly have) extracted out either a `local` variable or a module-level `var`. There's certainly a guiding principle as to when to extract variables, but ... (handwaving) go read a book.

#### Alternate Solutions

- Import the resource into terraform, so you can replace the data block with a `resource`. Pinocchio is a real boy now! Pinocchio is a real boy who is managed by Terraform, with all that entails. This is probably the best solution, so long as you're able to enact it.
- As the GitHub Issue mentions, avoid `depends_on`, especially if you don't need it.

#### More Alternate "Solutions"

- "Hello, Pulumi Incorporated? Yes? I hear you like both **customers** and **money**? Yes? That's great! I'll be right over!"
- Move into the mountains, live off of the land, make your own clothing. Don't worry about medical care, just crush up leaves and rub them on whatever's ailing you, and breathe in that fresh mountain air. Invigorating! Use your old work laptop as part of the shelter--a constant reminder of the old world and why you left it behind. If you're honest, it's miserable in the wild, but at least you don't have to deal with Terraform. That's what you tell yourself as you rub more crushed leaves on the rash. The rash is still growing, and it's starting to burn now more than itch. It's cold. Cold in the mountains.

#### Political Advocacy and a cry for help

I have several things to say:

1. Political advocacy: I blame HashiCorp for casually tossing data blocks around in the documentation. Put a stern warning in there, Hashicorp. These things are _productivity landmines_.
1. Hashicorp: seriously, these things are dangerous. `terraform validate` should warn me for every single data block I use. Sure, some data blocks can be used safely, as can some sticks of dynamite. But let's put some guardrails on these things, okay?
1. Am I missing something? I feel like I'm missing something obvious, and I wasted all this time writing up the issue, when (_insert your simple explanation_).

Seriously, let me know if I'm doing something wrong. @pseale on twitter or `peter` `@` `pseale.com`.
