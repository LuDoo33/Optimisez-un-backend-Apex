public without sharing class MyTeamOrdersController {
    public decimal SumOders {
        get {
            AggregateResult groupedResults = [SELECT SUM(TotalAmount) total 
                                              FROM Order 
                                              WHERE Status = 'Ordered'];
            return groupedResults.get('total') != null ? (decimal)groupedResults.get('total') : 0;
        }
        set;
    }
}
