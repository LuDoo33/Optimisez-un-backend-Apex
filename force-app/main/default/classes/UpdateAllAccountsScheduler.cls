global class UpdateAllAccountsScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        UpdateAllAccounts batch = new UpdateAllAccounts();
        Database.executeBatch(batch, 200);
    }
}
