global class UpdateAllAccountsScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        // Appel du batch UpdateAllAccounts sans namespace
        UpdateAllAccountsBatch batch = new UpdateAllAccountsBatch();
        Database.executeBatch(batch, 200);  // Limite de 200 enregistrements par exécution de batch
    }
}
