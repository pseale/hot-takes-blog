+++
title = "Vertical Slices, Jr: Easy, Flexible, Ideal Architecture For Small Projects"
tags = []
date = "2022-05-25"
draft = true
+++

##### Spicy Peppers Rating System | 🌶🌶 - Two Peppers | Disturbing Violence Against Repositories and the Prevailing Wisdom

### Summary

Vertical Slices is an excellent architecture regularly promoted by Jimmy Bogard. What I describe here is still vertical slices, but remains silent on every other architectural aspect. Here goes:

- Organize your core application logic into Commands and Queries.
- Add no additional abstractions until justified.
- As a direct implication of this, stop adding Repositories. They're not working.
- Exceptions made: if you're writing an application that is mostly CRUD, Vertical Slices is an inappropriate. What **is appropriate** is to go build a bunch of Google Forms, 'ship' those to your users, and finish your two-year project in an afternoon. You're welcome.

Read on and I'll do my best to convince you that, by the end, this is an ideal setup. Or at least, I'm not totally crazy.

### Services: an elegant weapon for a more civilized age

In the beginning (2002), Martin Fowler wrote [PoEAA](https://www.martinfowler.com/eaaCatalog/). And it was good! He recommended, among many good things, separating code into a Service Layer (which we will discuss). And everyone read the holy texts. Still good! Unfortunately for us, every five years, the number of programmers doubled. And at some point, people stopped reading the holy texts. Certainly I didn't read it. If I owned a copy of PoEAA, which I honestly can't recall, it would have been on my shelf, unread, in mint condition, next to Eric Evans' DDD book I also never read.

Anyway, in this savage prehistoric time, certainly his descriptions of common application architecture were appropriate. Remember, many of us still believed that the apex of ideal software engineering involved non-coding architects drawing diagrams in Rational Rose. And others of us did serious work in VBA. There were serious discussions about Truly Relational Database Management Systems (6NF, it's real) and how much better they were. It was a wild time, when monsters roamed the earth.

So let me be clear: there is nothing wrong with (Services)[https://martinfowler.com/eaaCatalog/serviceLayer.html]. We still need separation between the outward-facing UI, which keeps careful watch on inputs, and the gooey center. We need a seam.

But I choose to organize a little differently. What I propose is just a little twist away from a Service. Here we go.

### Commands and Queries: single-serving Services

**Commands** are Services that do an entire, single Thing.

**Queries** and Services that do an entire, single Query (that gets things).

By contrast, **Services** (in modern parlance) are bundles of behavior vaguely cohesive around a single Something, and does as many Things as it feels like.

I'll discuss pros-and-cons later. But now: concrete examples! Let's take a look:

### Commands and Queries: Example Time

```csharp
// TODO - service example
```

Shown above is a simple Service, calling a simple Repository, saving stuff to the database. This exemplifies the 2022 zeitgeist of the default enterprise architecture I call 'The Martin Fowler Telephone Game'--retaining the form--but not the power--of the original.

```csharp
// TODO - command/query example
```

Shown above is a Command, directly saving stuff to the database. There is no separation of data access logic from the 'Service Layer'. There is no need for it! Swallow your fear and trod onward, friends, stepping over the remains of the many dead layers. So many dead. Friends, we march onward--to glory!

### Benefits

- **Benefits of Service Layer** - separates the UI from everything else, exposing the smallest-possible contract, encapsulating the details. We're tearing down the walls, but leaving this wall standing! It's a good wall. (Service Layer bliki page)[https://martinfowler.com/eaaCatalog/serviceLayer.html]
- **Testable seam** - the lot of you are unready to hear this truth, but the appropriate Unit for a Unit Test is either a single Command, or a single Query. Buy into this idea and you'll be living your best life today. These tests will be easy to Arrange, trivial to Act, easy to Assert. They'll be fast, they'll be easy to change, fix, write, and most importantly, understand. I'm getting lost in the details, so let me say it clearly: testing will be superior in every way. (The topic of testing deserves its own blog post. Later.)
- **Allows for growth, and if necessary, ejecting** - organizing by Commands and Queries
