
+++
title = "CQ Baby: Ideal Architecture For Smaller Projects"
tags = []
date = "2022-05-12"
draft = true
+++

### Summary

cq-baby is perfect for any small app. It's robust, pragmatic, easy to learn, easy to teach, easy to know if you're abiding by The Rules, and best of all, when the right time comes--easy to eject out of.

Here's what it is:
* For each Thing your app does, create either a single Command or a single Query.
* Every other abstraction has to justify itself (most can't).
* Don't do anything crazy.

There are a many benefits to this approach, which I will elucidate below.

### Organize by Commands and Queries

The first rule of cq-baby is that everything is either a Command or a Query. Let's do this by example:

- One Per HTTP API Endpoint - `/api/book-flight` -> `BookFlightCommand`
- One Per Entire Page - `/book-a-flight` -> the entire page, I repeat the **entire** page is powered by a single `BookFlightQuery`
- One Per AJAX Call - `GET /api/flights` -> `GetFlightsQuery` - try and consolidate if possible
- One Per SignalR Message - `connection.invoke("SendMessage", message)` -> `BookFlightCommand`
- One Per Background Job - `UpdateFlightsFromSAPJob` -> `UpdateFlightsFromSAPCommand`
- One Per RabbitMQ Consumer - `FlightUpdatedMessageConsumer` -> `UpdateFlightCommand`
- One Per ETL Transaction (any Load into your database is a Command)

As much as you are tempted, you are **not permitted** to call two or more Queries or Commands when doing a single Thing. These do **not replace method calls**. You are certainly permitted to make method calls from within the Command or Query! And we'll talk about justifiable abstractions later. For now, just know that Commands and Queries are clearly identifiable boundaries.

Commands and Queries are a single, strong boundary that separates the filthy, messy Outside, from the carefully-guarded Inside. Yes, this is the basic idea of hexagonal architecture--it is nothing new.

Further, Commands are not Queries. Queries get things, Commands do things. There are only a few types of weird situations where this gets fuzzy. Queries that are so heavyweight that you must run them asynchronously, in the background, and write the results out to a data store--these are queries in the logical sense, yes, but for our purposes they are Commands. `RunAdvancedDeepLearningJobCommand` is an extreme example because nobody thinks about AI pipelines as ad-hoc queries, but in the end

There are many similar ideas, and this is nothing new or revolutionary. We have Event-Driven Architectures, DDDD/CQRS, we've got Clean, we've got hexagons, we've got onions, we've got vertical slices (which, by the way, I'm aware is VERY similar). But I have a few novel ideas, and I want to unleash them on the world, like a disease, causing a **global pandemic of simplicity**.

#### Benefit: Vertical Slices

If I'm honest, 
#### Benefit: Enlightened Integration Testing

There's a lot of bad teaching about unit testing, and a lot of you have bought into it, and so things that are obvious to me seem revolutionary. Anyway I'm here to add more vitriol and confusion, and let me start by saying that **the correct Unit of Unit Testing is an entire Command, or an entire Query**.

I'm sure you've seen advocates for smaller Units, testing collaboration between objects. Well, they're wrong, and they're Java programmers. But I repeat myself. Those tests are mostly useless and you can throw them away. With Enlightened Integration Testing, you will write the great majority of your tests against the strong boundary created by Commands and Queries:

``` csharp
// Arrange
UpdateFlightsFromSAPCommand.Execute(new { From = "LAX", To = "LGA" });

// Act
BookFlightCommand.Execute("LAX->LGA", DateTime.Parse("2022-01-01Z"), "flyer@example.com");

// Assert
var results = UpcomingFlightDetailsQuery.Execute("flyer@example.com");
Assert.AreEqual(1, results.Count());
AssertFlightDetailsAreCorrect(results[0], DateTime.Parse("2022-01-01Z"), "LAX->LGA");
```

I'll still allow you, out of the goodness of my heart, to write micro-sized Unit tests, which are still greatly useful in situations where you need help breaking down the problem into bite-sized chunks of work, or maybe where you have truly complex behavior that is best tested with finer-grained unit tests. It's ok and I need small tests too sometimes. For example, if you're building the flight booking price calculator, you're probably not going to sit down, write an Enlightened Integration Test for booking a flight that includes all of the complex and possibly predatory pricing rules, followed by 40-160 hours of working with failing tests.

Unit tests are also useful when you're learning to program, and I don't mean that in an offensive way. Well, you might be offended when you realize that you, a Senior Developer, still need to learn to program. But I'm trying to be nice. Unit tests are indeed helpful as a feedback mechanism that tell you, e.g. your `FlightPricingHelper` is easy to test, therefore (assuming your tests are sane) will be equally easy to use in production code, and so you can be reasonably certain that you're **the greatest programmer who has ever lived**.

Enlightened Integration Tests are foremost useful, fast, easy to understand, easy to set up, easy enough to verify, are **not brittle**.

**Useful:** 

And, if you take your `IFlightService` and `IFlightRepository` and inline the repository, then split `IFlightService` by method into specific Commands and Queries, congratulations--  


The two things I'm trying to kill with this architecture are:
- The inevitable .NET architecture best described as the Martin Fowler Telephone Game, in which someone (only one person) read quite good advice on the bliki back in 2005, and passed that advice through six or seven intermediaries--like the Telephone Game! I suppose I could also refer to this as a 'cargo cult' architecture, but I'll be honest and admit that I forgot what the point of referring to things as 'cargo cult' means, exactly. Anyway, the architecture is bad.
- 
