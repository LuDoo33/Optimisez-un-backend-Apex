trigger OrderTrigger on Order (before update, after update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        // Logique du trigger before update
        OrderTriggerHandler.beforeUpdate(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        // Logique du trigger after update
        OrderTriggerHandler.afterUpdate(Trigger.new);
    }
}
