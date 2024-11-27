public class OrderTriggerHandler {

    public static void beforeUpdate(List<Order> newOrders) {
        // Étape 1 : Calcul du montant net pour chaque commande
        calculateNetAmount(newOrders);
    }

    public static void afterUpdate(List<Order> newOrders) {
        // Étape 1 : Identifier les comptes concernés
        Set<Id> accountIds = getAccountIds(newOrders);

        // Étape 2 : Calculer les ventes totales par compte et mettre à jour les comptes
        if (!accountIds.isEmpty()) {
            updateAccountSales(accountIds);
        }
    }

    // **Méthodes auxiliaires**

    /**
     * Calcule le montant net pour chaque commande.
     * Montant net = TotalAmount - ShipmentCost.
     */
    private static void calculateNetAmount(List<Order> orders) {
        for (Order order : orders) {
            Decimal totalAmount = getDecimalValue(order.TotalAmount);
            Decimal shipmentCost = getDecimalValue(order.ShipmentCost__c);
            order.NetAmount__c = totalAmount - shipmentCost;

            // Logs de débogage
            System.debug('Order ID: ' + order.Id);
            System.debug('TotalAmount: ' + totalAmount);
            System.debug('ShipmentCost: ' + shipmentCost);
            System.debug('NetAmount: ' + order.NetAmount__c);
        }
    }

    /**
     * Récupère l'ensemble des IDs de comptes liés aux commandes.
     */
    private static Set<Id> getAccountIds(List<Order> orders) {
        Set<Id> accountIds = new Set<Id>();
        for (Order order : orders) {
            if (order.AccountId != null) {
                accountIds.add(order.AccountId);
            }
        }
        return accountIds;
    }

    /**
     * Met à jour les ventes totales (chiffre d'affaires) des comptes.
     * Se base sur les commandes liées ayant le statut 'Ordered'.
     */
    private static void updateAccountSales(Set<Id> accountIds) {
        // Étape 1 : Récupérer les commandes liées aux comptes concernés
        Map<Id, Decimal> accountSalesMap = getAccountSalesMap(accountIds);

        // Étape 2 : Mise à jour des comptes avec les chiffres d'affaires calculés
        updateAccounts(accountSalesMap);
    }

    /**
     * Récupère la carte des ventes totales par compte.
     */
    private static Map<Id, Decimal> getAccountSalesMap(Set<Id> accountIds) {
        Map<Id, Decimal> accountSalesMap = new Map<Id, Decimal>();
        List<Order> relatedOrders = [
            SELECT AccountId, TotalAmount
            FROM Order
            WHERE AccountId IN :accountIds AND Status = 'Ordered'
        ];

        for (Order order : relatedOrders) {
            if (order.TotalAmount != null) {
                Decimal currentTotal = accountSalesMap.containsKey(order.AccountId)
                    ? accountSalesMap.get(order.AccountId)
                    : 0;
                accountSalesMap.put(order.AccountId, currentTotal + order.TotalAmount);
            }
        }
        return accountSalesMap;
    }

    /**
     * Met à jour les comptes avec les chiffres d'affaires calculés.
     */
    private static void updateAccounts(Map<Id, Decimal> accountSalesMap) {
        List<Account> accountsToUpdate = buildAccountsToUpdate(accountSalesMap);

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    /**
     * Construit la liste des comptes à mettre à jour.
     */
    private static List<Account> buildAccountsToUpdate(Map<Id, Decimal> accountSalesMap) {
        List<Account> accountsToUpdate = new List<Account>();

        for (Id accountId : accountSalesMap.keySet()) {
            Decimal updatedSales = accountSalesMap.get(accountId);
            accountsToUpdate.add(new Account(Id = accountId, Chiffre_d_affaire__c = updatedSales));
        }

        return accountsToUpdate;
    }

    /**
     * Récupère la valeur décimale d'un champ, en retournant 0 si la valeur est nulle.
     */
    private static Decimal getDecimalValue(Decimal value) {
        return value != null ? value : 0;
    }
}
