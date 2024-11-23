trigger CalculMontant on Order (before update) {
    OrderTriggerHandler.beforeUpdate(Trigger.new);
    for (Order newOrder : Trigger.new) {
        // Utiliser un prix par défaut de 0.0 si le champ est null.
        Decimal totalAmount = (newOrder.TotalAmount == null) ? 0 : newOrder.TotalAmount;
        Decimal shipmentCost = (newOrder.ShipmentCost__c == null) ? 0 : newOrder.ShipmentCost__c;

        newOrder.NetAmount__c = totalAmount - shipmentCost;

        // Ajouter des logs pour le débogage
        System.debug('Order ID: ' + newOrder.Id);
        System.debug('TotalAmount: ' + totalAmount);
        System.debug('ShipmentCost: ' + shipmentCost);
        System.debug('NetAmount: ' + newOrder.NetAmount__c);
    }
}


