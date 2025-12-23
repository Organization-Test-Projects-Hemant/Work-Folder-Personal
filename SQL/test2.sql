--INTO Magneto.dbo.Transaction_Status_NetSuite_RRogers
SELECT
  t.id
, t.[status] AS TransactionStatus
, GETDATE() AS create_dt
, GETDATE() AS modified_dt
, GETUTCDATE() AS EffStartDate
, '2999-12-31 11:59:59.000' AS EffEndDate
, ts.[name] AS TransactionStatusName
FROM dbo.NetSuite_Transaction t
LEFT JOIN [EdwStage].[dbo].[NetSuite_TransactionStatus] ts on t.status = ts.id 
 and t.Type = ts.trantype
WHERE t.id = 401
--8284602

SELECT * FROM Magneto.dbo.Transaction_Status_NetSuite_RRogers

SELECT * FROM [EdwStage].[dbo].[NetSuite_TransactionStatus] WHERE trantype = 'Journal'


UPDATE dbo.NetSuite_Transaction SET modified_dt = GETDATE(), status = 'R' WHERE id = 401;