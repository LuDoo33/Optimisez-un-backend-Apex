public without sharing class MyTeamOrdersController {
    public decimal SumOders{
        get{
			AggregateResult groupedResults = [SELECT SUM(TotalAmount) total FROM Order WHERE Status = 'Ordered'];
			return (decimal)groupedResults.get('total');

        }
        set;
    }
}