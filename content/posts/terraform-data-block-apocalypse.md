+++
title = "Terraform Data Blocks: Ushering in the coming apocalypse"
tags = []
date = "2022-04-05"
+++

##### Spicy Peppers Rating System | 🌶 | One Pepper: Bold and Zesty; Potentially Misinformation

### Summary: Data Blocks for Dummies

Data blocks for dummies may be explained as follows: **you** are the dummy if you're using Terraform's `data` blocks. Every resource that relies on a data block is in danger of being replaced, because data blocks are evaluated after apply. It's just a matter of time.

I know the summary above didn't make sense, so read on.

### Data blocks explained

Data blocks, or [Data sources](https://www.terraform.io/language/data-sources) in Hashicorp's parlance, are conveniences that allow you to get at information. I'll refer to them as data blocks because in the code they are a `data {}` block. Hashicorp docs provide a [a good overview](https://www.terraform.io/language/data-sources).

As I've discovered, data blocks are convenient right up until Terraform wants to replace **the entire Kubernetes cluster**. Did I mention it was **the entire Kubernetes cluster**? Not a node pool, no, **the entire Kubernetes cluster**.

### The danger, by example

[This remarkably friendly GitHub issue](https://github.com/hashicorp/terraform/issues/28377) details the danger better than I can. But I'll try anyway.

Let's start with something fun and simple. Let's start in the happy land of Not Relying On Data Blocks.

```hcl
######################################
## Innocent and Pure: Not Relying On Data Blocks
######################################

# resource group already exists

resource "azurerm_storage_account" "example" {
  # note resource group and location are hardcoded strings - potential DRY violation!!! Call the cops
  resource_group_name      = "existing-resource-group"
  location                 = "West Europe"

  # ... (details omitted)
}
```

This works great for a single resource! Great work--you're the best!

So here's what we did next, when we realized we needed to reference the resource group name and location a bunch of times. So convenient! Let's call this scenario Impending Doom. This example is flawed, but **assume** the data block is needed. You can think up a real example. Examples are easy to find--just look anywhere in your own terraform!

```hcl
######################################
## Impending doom
######################################

# resource group already exists
data "azurerm_resource_group" "example" {
  name      = var.resource_group_name
  location  = var.resource_group_location
}

resource "azurerm_storage_account" "example" {
  # note resource group and location are bound to data block properties
  resource_group_name      = data.azurerm_resource_group.example.name
  location                 = data.azurerm_resource_group.example.location

  # ... (details omitted)
}
```

There are a few things wrong here. First: again, the data block is unnecessary in the example above, but imagine you did need the data block.

Second: while this works perfectly on the initial `terraform apply`, you are now in danger of replacing that resource at any moment.

Here's what `terraform plan` looks like some time in the future:

```hcl
######################################
## Your Doom - terraform plan output
######################################

# resource.azurerm_storage_account.example must be replaced
-/+ resource "azurerm_storage_account" "example" {
  location                 = "West Europe" -> (known after apply) # forces replacement

  # ... (omitted)
}
```

Congratulations, you're about to **replace all your infrastructure**!

#### Explanation

So let's walk through what happened, to the best of my understanding.

1. On first apply, when standing up the infrastructure from scratch, there are no problems.
1. On further applies, assuming nothing else has changed with the resource in question, there are no problems.
1. But on Doomsday, something in your infrastructure changes. (Honestly, details TBD--I'm still not sure what triggers this.)
1. On Doomsday, terraform attempts to plan the difference between your HCL and reality. And when it evaluates the `location` property, it cannot evaluate the results of the `data` block, because **data blocks are evaluated during apply**. Let that sink in. Data blocks are not evaluated during plan, but during apply. Not during plan. Not during plan. Am I crazy? Not during plan, but during apply.
1. Because it does not know the value of the (honestly truly important) `location` property, it doesn't know if the location's going to change, and makes a plan assuming it will change. So, to use Terraform's terminology, because it relies on a property `known after apply`, this `forces replacement`.
1. So as a result of you using a data block, which you did for just a little extra convenience, terraform wants to replace **the entire Kubernetes cluster**.
1. Though I haven't tested it, according to the GitHub Issue at https://github.com/hashicorp/terraform/issues/28377 - terraform is **not** bluffing and will indeed replace all your stuff.

If my frenzied, simplified, incoherent explanation didn't work for you, there are two authoritative answers on the GitHub Issue thread explaining what is truly happening:

- [First explanation](https://github.com/hashicorp/terraform/issues/28377#issuecomment-820398608)
- [Second explanation](https://github.com/hashicorp/terraform/issues/28377#issuecomment-824070018)

#### Solution

My solution is to stop using data blocks. Here's the fixed example:

```hcl
######################################
## The Path of Enlightenment: Not Relying On Data Blocks
######################################

# resource group already exists

resource "azurerm_storage_account" "example" {
  # note resource group and location are hardcoded strings - this is ok because the alternative (using a data block) is worse
  resource_group_name      = "existing-resource-group"
  location                 = "West Europe"

  # ... (details omitted)
}
```

Before enlightmentment: chop wood, carry water. After enlightenment: chop wood, carry water.

#### Political Advocacy and a cry for help

I have several things to say:

1. Political advocacy: I blame HashiCorp for casually tossing data blocks around in the documentation. Put a stern warning in there, Hashicorp. These things are _productivity landmines_.
1. Hashicorp: seriously, this is a nightmare. `terraform validate` should warn me for every single data block I use. Sure, some data blocks can be used safely, as can some sticks of dynamite. But let's put some guardrails on these things, okay?
1. AM I CRAZY!!?!?!????! HAVE I GONE INSANE!?!???!? AM I ALONE IN THIS STRUGGLE!?!????? I wrote this post as a way of trying to figure out if I'm doing something horribly wrong. Am I? Is there an easier way to resolve this problem? Am I making faulty assumptions? Let me know. I am very experienced in the art of making bad assumptions and as a result, wasting hours of my own time.

Seriously, let me know if I'm doing something wrong.

#### Final note about modules, data blocks, and depends_on

According to the GitHub Issue https://github.com/hashicorp/terraform/issues/28377, this problem is caused by specific interactions between data blocks, modules, and depends_on. I guess? Given how many times I've run into this--something's deeply wrong?
