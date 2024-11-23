trigger CalculMontant on Order (before update) {
    // Toute la logique est déléguée au handler
    OrderTriggerHandler.beforeUpdate(Trigger.new);
}
