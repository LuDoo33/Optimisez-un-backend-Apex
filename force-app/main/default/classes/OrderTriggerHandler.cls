public class OrderTriggerHandler {

    public static void beforeUpdate(List<Order> newOrders) {
        for (Order newOrder : newOrders) {
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

    public static void afterUpdate(List<Order> newOrders) {
        // Collecte les IDs des comptes liés aux commandes
        Set<Id> accountIds = new Set<Id>();
        for (Order newOrder : newOrders) {
            if (newOrder.AccountId != null) {
                accountIds.add(newOrder.AccountId);
            }
        }

        if (!accountIds.isEmpty()) {
            // Récupère toutes les commandes des comptes concernés ayant le statut 'Ordered'
            Map<Id, Decimal> accountSalesMap = new Map<Id, Decimal>();
            List<Order> relatedOrders = [
                SELECT AccountId, TotalAmount
                FROM Order
                WHERE AccountId IN :accountIds AND Status = 'Ordered'
            ];

            // Calcul des ventes totales pour chaque compte
            for (Order order : relatedOrders) {
                if (order.TotalAmount != null) {
                    if (accountSalesMap.containsKey(order.AccountId)) {
                        accountSalesMap.put(order.AccountId, accountSalesMap.get(order.AccountId) + order.TotalAmount);
                    } else {
                        accountSalesMap.put(order.AccountId, order.TotalAmount);
                    }
                }
            }

            // Récupérer les comptes à mettre à jour
            List<Account> accountsToUpdate = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountIds];

            for (Account acc : accountsToUpdate) {
                acc.Chiffre_d_affaire__c = accountSalesMap.get(acc.Id);
            }

            // Mise à jour en masse des comptes
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
        }
    }
}
