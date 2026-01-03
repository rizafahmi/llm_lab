# Prompt History

## Planning
Based on @docs/spec.md break the implementation into logical bite-sized task or milestones for developer to start working. Save it as @docs/plan.md


### Revision to use outside-in approach

I want to do this kind of style of TDD or BDD from the outside-in. This means that we will start writing features from the outside, using feature tests to describe the behavior of the application inside @test/llm_lab_web/features/ folder. When the feature test fails (red) for some of our business logic, we'll drop into the inner circle and follow the TDD approach for our business logic — red, green, and refactor. Once we finish a red-green-refactor cycle inside, we'll step back out to the feature test to see (a) if we have moved one step further in the feature test and thus have another failure to step into, or (b) if we have made the feature test pass (green). At that point, we will refactor the whole feature. With that in mind, let's revise our plan.
