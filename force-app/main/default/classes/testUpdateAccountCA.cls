@isTest
private class TestUpdateAccountCA {
    @isTest static void test() {
        Account acc1 = new Account(Name = 'Test Account 1');
        insert acc1;

        Product2 pd1 = new Product2(Name = 'Chemise Verte longue XYX', Family = 'Chemise');
        insert pd1;

        // Use Test.getStandardPricebookId() to fetch the Standard Pricebook ID
        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pd1.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        insert pbe;

        Order o1 = new Order(
            AccountId = acc1.Id,
            Pricebook2Id = pricebookId, // Assign the same Standard Pricebook ID to the Order
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
        insert o1;

        OrderItem oi1 = new OrderItem(OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity = 10, UnitPrice = 150);
        insert oi1;
        OrderItem oi2 = new OrderItem(OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity = 20, UnitPrice = 1000);
        insert oi2;
    }
}
