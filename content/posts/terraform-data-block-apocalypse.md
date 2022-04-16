+++
title = "Terraform Data Blocks: Lurking Danger"
tags = []
date = "2022-04-14"
+++

##### Spicy Peppers Rating System | 🌶 | One Pepper: Bold and Zesty; Potentially Misinformation

### Summary: Data Blocks

Data blocks (Terraform Data sources) appear harmless, but aren't. This is because every resource that relies on a data block is in danger of being replaced, because data blocks can be evaluated **after apply**. It's just a matter of time.

I know the summary above didn't make sense, so read on.

### Data blocks explained

Data blocks, or [Data sources](https://www.terraform.io/language/data-sources) in Hashicorp's parlance, are a convenient way to get at information. I'll refer to them as data blocks because in the code they are a `data {}` block. If you're entirely unfamiliar with them, Hashicorp docs provide a [a good overview](https://www.terraform.io/language/data-sources).

As I've discovered, data blocks are convenient right up until Terraform wants to replace **the entire Kubernetes cluster**. Did I mention it was **the entire Kubernetes cluster**? Not just a node pool, no, **the entire Kubernetes cluster**. And as bad as that sounds, it was worse, actually: yes, it was **the entire Kubernetes cluster**, but it was also almost everything else, too.

### The danger, by example

[This remarkably friendly GitHub issue](https://github.com/hashicorp/terraform/issues/28377) details the danger better than I can. But I'll try anyway.

Let's start with something fun and simple: living in the happy land of Primal Innocence. The Beginning.

```hcl
######################################
## Primal Innocence: Not Relying On Data Blocks
######################################

# subnet already exists, not managed by terraform

resource "azurerm_network_interface" "example" {
  # note it's a hardcoded string - a potential DRY violation! Call the cops
  subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/examplerg/providers/Microsoft.Network/virtualNetworks/examplevnet/subnets/subnet1"

  # ... (details omitted)
}
```

This works great! To specify which subnet to place the `azurerm_network_interface` in, we've hardcoded the `subnet_id`. This works, it's safe, and any potential mistakes can be discovered during a `terraform plan` ... but it's ugly? It's hard to read?

So here's what we did next. So convenient! Let's call this scenario Trouble Ahead: Storm's A-brewin'.

```hcl
######################################
## Trouble Ahead: Storm's A-brewin'
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

While this works perfectly on the initial `terraform apply`, we are now in danger of replacing our `azurerm_network_interface` resource.

The danger is not immediate--so far, we're still safe. To fall fully into the trap, we need to do a few specific, reasonable-seeming things:

- Use a data block in a module
- Use outputs from that module
- Explicitly `depends_on` that module

Let's see what such a disaster looks like:

```hcl
######################################
## Imminent doom
######################################

# assume this module relies on the same data block, under the hood
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
######################################
## Your Doom - terraform plan output
######################################

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
1. Presumably (and this is speculation), terraform can't know the value of the output of the module until during apply of the module, and because of this, it doesn't know if values will change.
1. Therefore, it chooses the only predictable choice, and assumes that yes, the value will change.
1. And if this forces replacement of an entire resource, well, so be it.
1. Anyway a big chunk of our infrastructure is now cursed by the dreaded `-> (known after apply) # forces replacement` message.

Let me attempt to explain this in a different way:

1. There is a gun on the mantle.
1. We pick up the gun. While it's not loaded (at least the last time we checked), it is at this point we should treat it as loaded.
1. A great deal of time passes. What adventures we've had! What sights we've seen! Oh, if only I had time to tell the tale!
1. And through an unlikely series of events, we load the gun and point it at our foot. Ominous foreboding.
1. More adventures!
1. Sometime later, while tagging our infrastructure in terraform, the gun discharges. Friend, we've just shot ourselves in the foot. I can't believe it either, but here we are.

In this colorful allegory, data blocks are the gun, and the unlikely series of events were in my case, quite common. And my point here is, while we see data blocks as harmless conveniences, we should treat them instead as a potentially loaded gun, one which may fire at any moment.

And though I haven't tested it, according to the GitHub Issue at https://github.com/hashicorp/terraform/issues/28377 - terraform is **not bluffing** and will indeed replace all of our resources.

If my explanation didn't work for you, there are two succinct, authoritative answers on the GitHub Issue thread explaining what's happening, though to their detriment they do _not_ fire any guns or reference a three-act structure in their explanations:

- [First explanation](https://github.com/hashicorp/terraform/issues/28377#issuecomment-820398608)
- [Second explanation](https://github.com/hashicorp/terraform/issues/28377#issuecomment-824070018)

#### Solution

My solution is to stop using data blocks. Here's the fixed example:

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

And while I've hardcoded the `subnet_id` in the enlightened example above, I would (and certainly have) extracted out either a `local` variable or a module-level `var`. And there's a guiding principle as to when to extract variables, but ... (handwaving) go read a book.

#### Alternate Solutions

- Import the resource into terraform, so we can replace the data block with a `resource`. Pinocchio is a real boy now! Pinocchio is a real boy who is managed by Terraform, with all that entails.
- As the GitHub Issue mentioned, avoid `depends_on`, especially if we don't need it.
- "Hello, Pulumi Incorporated? Yes? I hear you like both **customers** and **money**? Yes? That's great! I'll be over immediately!"
- Move into the mountains, live off of the land, make your own clothing. Don't worry about medical care, just rub some leaves on whatever's ailing you and breathe in that fresh mountain air. Use your old work laptop as part of the shelter--a constant reminder of the old world and why you left it behind. If you're honest, it's miserable in the wild, but at least you don't have to deal with Terraform. That's what you tell yourself as you rub more leaves on the rash. The rash is still growing, and it's more of a burning sensation now than an itch. It's cold. Cold in the mountains.

#### Political Advocacy and a cry for help

I have several things to say:

1. Political advocacy: I blame HashiCorp for casually tossing data blocks around in the documentation. Put a stern warning in there, Hashicorp. These things are _productivity landmines_.
1. Hashicorp: seriously, these things are dangerous. `terraform validate` should warn me for every single data block I use. Sure, some data blocks can be used safely, as can some sticks of dynamite. But let's put some guardrails on these things, okay?
1. Am I missing something? I feel like I'm missing something obvious, and I wasted all this time writing up the issue, when (_insert your simple explanation_).

Seriously, let me know if I'm doing something wrong. @pseale on twitter or `peter` `@` `pseale.com`.
