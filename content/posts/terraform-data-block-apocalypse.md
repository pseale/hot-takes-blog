+++
title = "Terraform Data Blocks: Ushering in the coming apocalypse"
tags = []
date = "2022-04-14"
+++

##### Spicy Peppers Rating System | 🌶 | One Pepper: Bold and Zesty; Potentially Misinformation

### Summary: Data Blocks for Dummies

Data blocks for dummies may be explained as follows: **you** are the dummy if you're using Terraform's `data` blocks (Terraform Data sources). This is because every resource that relies on a data block is in danger of being replaced, because data blocks can be evaluated **after apply**. It's just a matter of time.

I know the summary above didn't make sense, so read on.

### Data blocks explained

Data blocks, or [Data sources](https://www.terraform.io/language/data-sources) in Hashicorp's parlance, are a convenient way to get at information. I'll refer to them as data blocks because in the code they are a `data {}` block. Hashicorp docs provide a [a good overview](https://www.terraform.io/language/data-sources).

As I've discovered, data blocks are convenient right up until Terraform wants to replace **the entire Kubernetes cluster**. Did I mention it was **the entire Kubernetes cluster**? Not a node pool, no, **the entire Kubernetes cluster**.

### The danger, by example

[This remarkably friendly GitHub issue](https://github.com/hashicorp/terraform/issues/28377) details the danger better than I can. But I'll try anyway.

Let's start with something fun and simple. Let's start in the happy land of Primal Innocence: The Beginning.

```hcl
######################################
## Innocent and Pure: Not Relying On Data Blocks
######################################

# subnet already exists, not managed by terraform

resource "azurerm_network_interface" "example" {
  # note it's a hardcoded string - a potential DRY violation!!! Call the cops
  subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/examplerg/providers/Microsoft.Network/virtualNetworks/examplevnet/subnets/subnet1"

  # ... (details omitted)
}
```

This works great! We have hardcoded the `subnet_id`. This works, it's safe, it can be tested via `terraform plan` ... but it's ugly? It's a little hard to read? I mean, yes, it's immediately obvious, easier to understand, and can be encapsulated later, but ... offends my aesthetic?

So here's what we did next, when we realized we needed to reference this kind of thing a bunch of times. So convenient! Let's call this scenario Trouble Ahead--Storm's A-brewin'.

```hcl
######################################
## Storm's A-brewin'
######################################

# resource group already exists
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

While this works perfectly on the initial `terraform apply`, you are now in danger of replacing your azurerm_network_interface resource.

The bomb hasn't exploded yet. The danger isn't imminent, and may never come! But the danger is there. To explode this bomb, you need to do a few specific, reasonable-seeming things:

- Use a data block in a module
- Use outputs from module
- Explicitly `depends_on` that module

Let's see what such a **disaster** looks like:

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

Here's what `terraform plan` looks like some time in the future, after you make an innocent change somewhere in the neighborhood. In my case, tagging. Tagging is like the Stay Puft Marshmallow Man. Tagging is the most harmless thing. Something that could never, ever, possibly destroy us!

(Also, for the record, I'm aware this is not a very fresh movie reference. Ghostbusters, released 1984.)

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

Congratulations, you're about to **replace all your infrastructure**!

#### Explanation

So let's walk through what happened, to the best of my understanding.

1. On first apply, when standing up the resource from scratch, there are no problems. Let's call this situation **there's a gun**. There's a gun, but no worries, it's just a gun sitting on the mantle, not loaded. It's just there, doing nothing. Harmless!
1. Later, you add a data block for convenience, to calculate an (honestly pretty ugly) subnet ID. I'll call this **picking up the gun**. No worries friends, it's not loaded. Sure, we'll pull the trigger during each and every `terraform apply` that touches this resource going forward, but no worries! It's not loaded! And it's safely pointed at the ground, next to your foot! This resource will never change! The gun's not even pointed at your foot!
1. Then, for any defensible reason, you move that data block inside of a module. It's DRY and SRP and so aesthetically pleasing! Well done! We now rely on a data block, which is **read during apply** of the module. Sounds troubling, but no worries--we can know its value just in time. Let's call this **loading the gun**. We're still firing the gun on `terraform apply`, but again, no worries! It's pointed _next_ to your foot, not _at_ it! Friends, computers are precise. The gun will _never_ waver. It will _always_ discharge immediately _next_ to your foot, as Hashicorp designed in all their wisdom.
1. Now here's where you made a mistake. You put a `depends_on` somewhere. I'm not sure why you did it either, and I'm quite frankly ashamed of all of us. This moves evaluation of the property to **after apply of the module**, which **forces replacement**. Friend, you've just shot yourself in the foot. I can't believe it either, but here we are. Again, and to use Terraform's terminology: because we rely on something `known after apply`, this `forces replacement`. To use my terminology: Whoops, and ow!
1. So because you used a data block, which you did for just a little extra convenience, terraform wants to replace everything.
1. Though I haven't tested it, according to the GitHub Issue at https://github.com/hashicorp/terraform/issues/28377 - terraform is **not** bluffing and will indeed replace all your stuff.

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

#### Alternate Solution

"Hello, Pulumi Incorporated? Yes? I hear you like **customers** and **money**? Yes? That's great! I'll be there in an hour!"

#### More Alternate Solutions

- Import the resource into terraform, so you can dump the data block and directly reference the `resource`. Pinocchio is a real boy now!
- As the GitHub Issue mentioned, avoid `depends_on`, especially if you don't need it.
- Move into the mountains, live off of the land, make your own clothing. Don't worry about medical care, just rub some leaves on it and breathe in that fresh mountain air. Use your old work laptop as part of the shelter--a constant reminder of the old world and why you left it behind. If you're honest it's miserable in the mountains, but at least you don't have to deal with Terraform. That's what you tell yourself as you rub more leaves on the rash. The rash is still growing, and it's more of a burning now than an itching. It's cold. Cold in the mountains.

#### Political Advocacy and a cry for help

I have several things to say:

1. Political advocacy: I blame HashiCorp for casually tossing data blocks around in the documentation. Put a stern warning in there, Hashicorp. These things are _productivity landmines_.
1. Hashicorp: seriously, this is a nightmare. `terraform validate` should warn me for every single data block I use. Sure, some data blocks can be used safely, as can some sticks of dynamite. But let's put some guardrails on these things, okay?
1. Am I missing something? I feel like I'm missing something obvious, and I wasted all this time writing up the issue, when (_insert your simple explanation_).

Seriously, let me know if I'm doing something wrong. @pseale on twitter or `peter` `@` `pseale.com`.
