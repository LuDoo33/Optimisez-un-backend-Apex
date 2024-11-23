trigger UpdateAccountCA on Order (after update) {
    // Toute la logique est déléguée au handler
    OrderTriggerHandler.afterUpdate(Trigger.new);
}
