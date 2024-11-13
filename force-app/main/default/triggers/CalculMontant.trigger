trigger CalculMontant on Order (before update) {
    for (Order newOrder : Trigger.new) {
        // Utiliser un prix par défaut de 0.0 si le champ est null.
        Decimal totalAmount = (newOrder.TotalAmount == null) ? 0 : newOrder.TotalAmount;
        Decimal shipmentCost = (newOrder.ShipmentCost__c == null) ? 0 : newOrder.ShipmentCost__c;

        newOrder.NetAmount__c = totalAmount - shipmentCost;
    }
}
