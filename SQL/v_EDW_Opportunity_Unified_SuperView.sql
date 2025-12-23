USE [Magneto]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_EDW_Opportunity_Unified_SuperView] AS

/****************************************************************************          
Name:           [v_EDW_Opportunity_Unified_SuperView]
Description:    Unified view combining PROD architecture with JT-View column completeness.
                Includes Change Tracking and SalesPotential aggregation.
****************************************************************************/

/* 1. Define Object Type Codes (OTCs) */
WITH cte_OpportunityBaseOTC AS (SELECT ObjectTypeCode FROM EdwStage.dbo.CRM_Entity ev WHERE ev.BaseTableName = 'OpportunityBase')
, cte_TerritoryBaseBaseOTC AS (SELECT ObjectTypeCode FROM EdwStage.dbo.CRM_Entity ev WHERE ev.BaseTableName = 'TerritoryBase')
, cte_SalesPotentialBaseOTC AS (SELECT ObjectTypeCode FROM EdwStage.dbo.CRM_Entity ev WHERE ev.BaseTableName = 'po_salespotentialBase')
, cte_CampaignBaseOTC AS (SELECT ObjectTypeCode FROM EdwStage.dbo.CRM_Entity ev WHERE ev.BaseTableName = 'CampaignBase')

/* 2. PROD-View Existing StringMaps (CTEs) */
,cte_StateCode AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'StateCode')
,cte_StatusCode AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'StatusCode')
,cte_SalesStageCode AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'salesstagecode')
,cte_SalesStage AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'salesstage')
,cte_ChancesOfWinning AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_ChancesOfWinning')
,cte_Forecasted AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_Forecasted')
,cte_LosttoCompetitorType AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_LosttoCompetitorType')
,cte_PaymentTerms AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_PaymentTerms')
,cte_QualifiesforIRSCredit AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_QualifiesforIRSCredit')
,cte_ReasonClosed AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_ReasonClosed')
,cte_SolutionApproved AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_SolutionApproved')
,cte_SolutionAssuranceRequired AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_SolutionAssuranceRequired')
,cte_SolutionFunded AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_SolutionFunded')
,cte_OpportunityType AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_OpportunityType')
,cte_QuickCreate AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_QuickCreate')
,cte_CopyOpportunity AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_CopyOpportunity')
,cte_WinLossStatus AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_WinLossStatus')
,cte_ExpiredOpp AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_ExpiredOpp')
,cte_CloudMSSalesStage AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_CloudMSSalesStage')
,cte_DedicatedTech AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_DedicatedTech')
,cte_PrimaryCSCSupport AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_PrimaryCSCSupport')
,cte_OpLinkedToAccountPlan AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_OpLinkedToAccountPlan')
,cte_Probability AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_Probability')
,cte_ReasonLost AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_ReasonLost')
,cte_Upside AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_Upside')
,cte_SuperTerritory AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_TerritoryBaseBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_SuperTerritory')
,cte_Zone AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_TerritoryBaseBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_Zone')
,cte_SPBStateCode AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_SalesPotentialBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'statecode')
,cte_SPBStatusCode AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_SalesPotentialBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'statuscode')
,cte_CampaignType AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_CampaignBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'TypeCode')
,cte_RVPBridgeOpportunity AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_RVPBridgeOpportunity')

/* 3. NEW CTEs ported from JT-Views (replacing LEFT JOIN StringMap) */
,cte_BudgetStatus AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'budgetstatus')
,cte_CaptureProposalFeedback AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'captureproposalfeedback')
,cte_new_GEMS AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'new_gems')
,cte_po_AutoCreated AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_autocreated')
,cte_po_AutoRoundUp AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_autoroundup')
,cte_po_ECommerce AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_ecommerce')
,cte_po_LCPRateCardEnabled AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_lcpratecardenabled')
,cte_po_LeadGeneratorRole AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_leadgeneratorrole')
,cte_po_Lease AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_lease')
,cte_po_LiftShiftReason AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_liftshiftreason')
,cte_po_LostSubReason AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_lostsubreason')
,cte_po_NoRounding AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_norounding')
,cte_po_OPidentifiedthroughWAVESorAdvisory AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_opidentifiedthroughwavesoradvisory')
,cte_po_OpportunityCategory AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_opportunitycategory')
,cte_po_OpportunityIdentifiedThrough AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_opportunityidentifiedthrough')
,cte_po_QuotesComplete AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_quotescomplete')
,cte_po_SalesPlay AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_salesplay')
,cte_po_ShiptoInstallAddress AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_shiptoinstalladdress')
,cte_po_ShiptoPRC AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_shiptoprc')
,cte_po_SoldasManagedServices AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'po_soldasmanagedservices')
,cte_PricingErrorCode AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'pricingerrorcode')
,cte_PriorityCode AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'prioritycode')
,cte_PurchaseProcess AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'purchaseprocess')
,cte_PurchaseTimeframe AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'purchasetimeframe')
,cte_PursuitDecision AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'pursuitdecision')
,cte_ResolveFeedback AS (SELECT smb.AttributeValue, smb.[Value] FROM EdwStage.dbo.CRM_StringMapBase smb JOIN cte_OpportunityBaseOTC otc ON smb.ObjectTypeCode = otc.ObjectTypeCode WHERE smb.AttributeName = 'resolvefeedback')


SELECT 
--Config+ChangeTracking (From PROD)
  'Opportunity' AS target_config
, ISNULL(change.SYS_CHANGE_VERSION,0) AS SYS_CHANGE_VERSION
, ISNULL(change.SYS_CHANGE_OPERATION,'I') AS SYS_CHANGE_OPERATION

--Data (Combined JT and PROD)
, opp.OpportunityId
, opp.po_Number AS OpportunityNumber
, opp.[Name] AS OpportunityName
, state_c.[Value] AS StateCode
, status_c.[Value] AS StatusCode
, opp.ParentAccountId AS AccountId -- GUID (PROD standard)
, opp.ParentAccountIdName -- Name (Added from JT)
, CAST(ab.AccountNumber AS NVARCHAR(20)) COLLATE SQL_Latin1_General_CP1_CI_AS AS CustomerId -- AccountNumber (PROD standard)
, ab.[Name] AS CustomerName

-- Customer/Account Info (Extended from JT)
, opp.CustomerId AS CustomerIdGUID -- Added from JT (Renamed to avoid collision with PROD CustomerId)
, opp.CustomerIdName
, opp.CustomerIdType
, opp.ParentContactId
, pcb.FullName AS ParentContactName -- PROD alias
, opp.ParentContactIdName -- JT alias redundancy (available if needed)

-- Owner/Team (Logic Merged)
, opp.OwningBusinessUnit AS SalesTeamId 
, bub.[Name] AS SalesTeam
, opp.OwnerId
, opp.OwnerIdType -- Added from JT
, own.FullName AS OwnerName -- PROD assumes User
-- Added JT Logic for User vs Team Owners
, CASE WHEN opp.OwnerIdType = 8 THEN opp.OwnerId ELSE NULL END AS OwningUser
, CASE WHEN opp.OwnerIdType = 9 THEN opp.OwnerId ELSE NULL END AS OwningTeam
, opp.po_OpportunityOwnerManager
, owmgr.FullName as po_OpportunityOwnerManagerName -- Added Join

-- Campaign (Combined)
, opp.CampaignId
, cmpb.[Name] AS CampaignName
, opp.po_SourceCampaign2 AS SourceCampaign2Id
, sc2.[Name] AS SourceCampaign2Name
, opp.po_sourcecampaign3 AS SourceCampaign3Id
, sc3.[Name] AS SourceCampaign3Name
, cmpb.TypeCode AS CampaignTypeId
, cpt1.[Value] AS CampaignType
, sc2.TypeCode AS SourceCampaign2TypeId
, cpt2.[Value] AS SourceCampaign2Type
, sc3.TypeCode AS SourceCampaign3TypeId
, cpt3.[Value] AS SourceCampaign3Type

-- Financials (PROD Basic + JT Extended)
, opp.EstimatedValue
, opp.ActualValue -- Added from JT
, opp.BudgetAmount -- Added from JT
, cte_BudgetStatus.[Value] AS BudgetStatus -- Added from JT
, opp.DiscountAmount -- Added from JT
, opp.DiscountPercentage -- Added from JT
, opp.FreightAmount -- Added from JT
, opp.TotalAmount -- Added from JT
, opp.TotalAmountLessFreight -- Added from JT
, opp.TotalDiscountAmount -- Added from JT
, opp.TotalLineItemAmount -- Added from JT
, opp.TotalLineItemDiscountAmount -- Added from JT
, opp.TotalTax -- Added from JT
, opp.po_EstimatedOpportunityValueHardwareNew -- Added from JT
, opp.po_EstimatedOpportunityValueHardwareRefurb -- Added from JT
, opp.po_EstimatedOpportunityValueMaintInHouse -- Added from JT
, opp.po_EstimatedOpportunityValueMaintResale -- Added from JT
, opp.po_EstimatedOpportunityValueManagedServices -- Added from JT
, opp.po_EstimatedOpportunityValueProServ -- Added from JT
, opp.po_EstimatedOpportunityValueSoftware -- Added from JT
, opp.po_OriginalContractValue -- Added from JT
, opp.TransactionCurrencyId -- Added from JT
, t.CurrencyName AS TransactionCurrencyIdName -- Added from JT

-- Sales Process & Dates
, opp.StepName
, stage_c.[Value] AS SalesStage
, stagecode_c.[Value] AS SalesStageCode
, opp.EstimatedCloseDate
, opp.ActualCloseDate
, opp.CloseProbability
, opp.CustomerNeed
, cowc.[Value] AS ChancesOfWinning
, prob.[Value] AS Probability
, opp.po_ClosedNotes AS ClosedNotes
, opp.po_OpportunityNotes AS OpportunityNotes
, opp.Description

-- Invoicing Dates (From PROD)
, opp.po_EstHardwareInvoiceDate AS EstimatedHardwareInvoiceDate
, opp.po_EstMaintInvoiceDate AS EstimatedMaintenanceInvoiceDate
, opp.po_EstServiceInvoiceDate AS EstimatedServiceInvoiceDate
, opp.po_EstSoftwareInvoiceDate AS EstimatedSoftwareInvoiceDate

-- Forecast (From PROD + JT)
, fc.[Value] AS Forecasted
, opp.po_ForecastedSolutionMargin AS ForecastedSolutionMargin
, opp.po_ForecastedSolutionRevenue AS ForecastedSolutionRevenue
, cu.[Value] AS Upside

-- Competitor/Loss Info
, lct.[Value] AS LostToCompetitorType
, rc.[Value] AS ReasonClosed
, rl.[Value] AS ReasonLost
, cb.[Name] AS LosttoBusinessPartner
, opp.po_LosttoBusinessPartner AS LosttoBusinessPartnerId -- Added from JT
, mb.[po_name] AS LostToManufacturer
, opp.po_LosttoManufacturer AS LosttoManufacturerId -- Added from JT
, wls.[Value] AS WinLossStatus
, cte_po_LostSubReason.[Value] AS LostSubReason -- Added from JT

-- Operational/Classification
, pt.[Value] AS PaymentTerms
, qfic.[Value] AS QualifiesforIRSCredit
, sa.[Value] AS SolutionApproved
, sar.[Value] AS SolutionAssuranceRequired
, sf.[Value] AS SolutionFunded
, pos.po_name AS SalesId
, sb.po_name AS PrimarySystem
, opp.po_PrimarySystem AS PrimarySystemId -- Added from JT
, ssar.FullName AS SolutionAssuranceResource
, opt.[Value] AS OpportunityType
, qc.[Value] AS QuickCreate
, pmb.po_name AS PrimaryManufacturer
, opp.po_PrimaryManufacturer2 AS PrimaryManufacturer2Id -- Added from JT
, cop.[Value] AS CopyOpportunity
, opp.po_ConnectWiseProjectID AS ConnectWiseProjectID
, ppb.po_name AS PrimaryPractice
, opp.po_PrimaryPractice AS PrimaryPracticeId -- Added from JT
, eop.[Value] AS ExpiredOpp
, cmss.[Value] AS CloudMSSalesStage
, dt.[Value] AS DedicatedTech
, pcsc.[Value] AS PrimaryCSCSupport
, olta.[Value] AS OpLinkedToAccountPlan
, opp.OriginatingLeadId
, lead.FullName AS OriginatingLeadIdName -- Added from JT
, opp.po_erpmasterordersubscription AS MasterOrderSubscription

-- Snapshot Dates (From PROD)
, opp.po_DateEnteredSS10 AS DateEnteredSS10
, opp.po_DateEnteredSS20 AS DateEnteredSS20
, opp.po_DateEnteredSS30 AS DateEnteredSS30
, opp.po_DateEnteredSS40 AS DateEnteredSS40
, opp.po_DateEnteredSS50 AS DateEnteredSS50
, opp.po_DateEnteredSS60 AS DateEnteredSS60
, opp.po_DateEnteredSS70 -- Added from JT

-- Territory/Region (PROD Logic)
, opp.po_TerritoryRegion AS RegionId
, COALESCE(st.[Value],tb.[Name],'Not Assigned') AS Region
, tb.[Name] AS TerritoryName
, tb.po_Zone AS ZoneId
, z.[Value] AS [Zone]
, tb.po_SuperTerritory AS SuperTerritoryId
, st.[Value] AS SuperTerritory

-- Audit Fields (Combined)
, opp.CreatedOn
, opp.CreatedBy -- Added ID from JT
, ISNULL(cobb_sub.FullName,cb_sub.FullName) AS CreatedByName -- PROD Logic
, opp.ModifiedOn
, opp.ModifiedBy -- Added ID from JT
, ISNULL(mobb_sub.FullName,mb_sub.FullName) AS ModifiedByName -- PROD Logic
, opp.CreatedOnBehalfBy
, cobb_sub.FullName AS CreatedOnBehalfByName -- Added from JT
, opp.ModifiedOnBehalfBy 
, mobb_sub.FullName AS ModifiedOnBehalfByName -- Added from JT

-- Extended Fields from JT (Not previously in PROD)
, opp.po_BillingAddress
, baddr.po_name AS po_BillingAddressName
, opp.po_ShiptoAddress
, saddr.po_name AS po_ShiptoAddressName
, opp.po_CompellingEvent
, opp.po_Competition
, opp.po_CustomerContact
, opp.po_CustomerPO
, opp.po_DataUpdate
, opp.po_datecommitted
, opp.po_DecisionCriteriaBusiness
, opp.po_DecisionCriteriaPolitical
, opp.po_DecisionCriteriaTechnical
, opp.po_DecisionProcess
, opp.po_EnterpriseArchitect
, eauser.FullName AS po_EnterpriseArchitectName
, opp.po_estimatedresaleservices
, opp.po_HowWeDoItBetter
, opp.po_ISR
, isruser.FullName AS po_ISRName
, opp.po_ITSMAgreementNumber
, opp.po_LeadGenerator
, leaduser.FullName AS po_LeadGeneratorName
, opp.po_MASR
, opp.po_MASRInstructions
, masr.FullName AS po_MASRName
, opp.po_MetricsNotes
, opp.po_NegativeConsequences
, opp.po_NegotiationGets
, opp.po_NewLeadGenerator
, opp.po_NextSteps
, opp.po_PaperProcess
, opp.po_PositiveBusinessOutcomes
, opp.po_PriceVarianceReason
, opp.po_ProofPoints
, opp.po_QualityGate2
, opp.po_RequiredCapabilities
, opp.po_RSM
, rsm.FullName AS po_RSMName
, opp.po_RSM_Critical
, crsm.FullName AS po_RSM_CriticalName
, opp.po_RSM_Strategic
, srsm.FullName AS po_RSM_StrategicName
, opp.po_RSM_Transactional
, trsm.FullName AS po_RSM_TransactionalName
, opp.po_SOWExecutiveSummary
, opp.po_SpecialShippingInstructions
, opp.po_TopThreeStrategicInitiativesorObjectives
, opp.ProcessId
, opp.ProposedSolution
, opp.QualificationComments
, opp.QuoteComments
, opp.StageId
, opp.StepId
, opp.TraversedPath
, opp.UTCConversionTimeZoneCode
, opp.VersionNumber 

-- JT Fields Mapped to New CTEs
, cte_CaptureProposalFeedback.[Value] AS CaptureProposalFeedback
, cte_new_GEMS.[Value] AS new_GEMS
, cte_po_AutoCreated.[Value] AS po_AutoCreated
, cte_po_AutoRoundUp.[Value] AS po_AutoRoundUp
, cte_po_ECommerce.[Value] AS po_ECommerce
, cte_po_LCPRateCardEnabled.[Value] AS po_LCPRateCardEnabled
, cte_po_LeadGeneratorRole.[Value] AS po_LeadGeneratorRole
, cte_po_Lease.[Value] AS po_Lease
, cte_po_LiftShiftReason.[Value] AS po_LiftShiftReason
, cte_po_NoRounding.[Value] AS po_NoRounding
, cte_po_OPidentifiedthroughWAVESorAdvisory.[Value] AS po_OPidentifiedthroughWAVESorAdvisory
, cte_po_OpportunityCategory.[Value] AS po_OpportunityCategory
, cte_po_OpportunityIdentifiedThrough.[Value] AS po_OpportunityIdentifiedThrough
, cte_po_QuotesComplete.[Value] AS po_QuotesComplete
, cte_po_SalesPlay.[Value] AS po_SalesPlay
, cte_po_ShiptoInstallAddress.[Value] AS po_ShiptoInstallAddress
, cte_po_ShiptoPRC.[Value] AS po_ShiptoPRC
, cte_po_SoldasManagedServices.[Value] AS po_SoldasManagedServices
, cte_PricingErrorCode.[Value] AS PricingErrorCode
, cte_PriorityCode.[Value] AS PriorityCode
, cte_PurchaseProcess.[Value] AS PurchaseProcess
, cte_PurchaseTimeframe.[Value] AS PurchaseTimeframe
, cte_PursuitDecision.[Value] AS PursuitDecision
, cte_ResolveFeedback.[Value] AS ResolveFeedback
, cte_RVPBridgeOpportunity.[Value] AS RVPBridgeOpportunity 

/* PROD Aggregated po_SalesPotentialBase Data (Kept as is) */
, spbrc.HardwareNewEstimatedCost
, spbrc.HardwareNewEstimatedRevenue
, spbrc.HardwareRefurbEstimatedCost
, spbrc.HardwareRefurbEstimatedRevenue
, spbrc.MaintenanceInHouseEstimatedCost
, spbrc.MaintenanceInHouseEstimatedRevenue
, spbrc.MaintenanceResaleEstimatedCost
, spbrc.MaintenanceResaleEstimatedRevenue
, spbrc.ManagedServicesEstimatedCost
, spbrc.ManagedServicesEstimatedRevenue
, spbrc.ProfessionalServicesEstimatedCost
, spbrc.ProfessionalServicesEstimatedRevenue
, spbrc.SoftwareEstimatedCost
, spbrc.SoftwareNewEstimatedRevenue
, spbrc.TotalEstimatedCost
, spbrc.TotalEstimatedRevenue

FROM EdwStage.dbo.CRM_OpportunityBase opp
-- Change Tracking (PROD)
LEFT JOIN CHANGETABLE(CHANGES EdwStage.dbo.CRM_OpportunityBase,0) change ON change.OpportunityId = opp.OpportunityId

-- Core Joins (PROD)
LEFT JOIN EdwStage.dbo.CRM_AccountBase ab ON opp.ParentAccountId = ab.AccountId
LEFT JOIN EdwStage.dbo.CRM_BusinessUnitBase bub ON opp.OwningBusinessUnit = bub.BusinessUnitId
LEFT JOIN EdwStage.dbo.CRM_CampaignBase cmpb ON opp.CampaignId = cmpb.CampaignId
LEFT JOIN EdwStage.dbo.CRM_SystemUserBase own ON opp.OwnerId = own.SystemUserId
LEFT JOIN EdwStage.dbo.CRM_ContactBase pcb ON opp.ParentContactId = pcb.ContactId
LEFT JOIN EdwStage.dbo.CRM_CompetitorBase cb ON opp.po_LosttoBusinessPartner = cb.CompetitorId
LEFT JOIN EdwStage.dbo.CRM_po_manufacturerBase mb ON opp.po_LostToManufacturer = mb.po_manufacturerId
LEFT JOIN EdwStage.dbo.CRM_po_salesidBase pos ON opp.po_SalesID = pos.po_salesidId
LEFT JOIN EdwStage.dbo.CRM_po_systemBase sb ON opp.po_PrimarySystem = sb.po_systemId
LEFT JOIN EdwStage.dbo.CRM_SystemUserBase ssar ON opp.po_SolutionAssuranceResource = ssar.SystemUserId
LEFT JOIN EdwStage.dbo.CRM_po_manufacturerBase pmb ON opp.po_PrimaryManufacturer2 = pmb.po_manufacturerId
LEFT JOIN EdwStage.dbo.CRM_TerritoryBase tb ON opp.po_TerritoryRegion = tb.TerritoryId
LEFT JOIN EdwStage.dbo.CRM_po_practiceBase ppb ON opp.po_PrimaryPractice = ppb.po_practiceId
LEFT JOIN EdwStage.dbo.CRM_SystemUserBase cobb_sub ON opp.CreatedOnBehalfBy = cobb_sub.SystemUserId
LEFT JOIN EdwStage.dbo.CRM_SystemUserBase cb_sub ON opp.CreatedBy = cb_sub.SystemUserId
LEFT JOIN EdwStage.dbo.CRM_SystemUserBase mobb_sub ON opp.ModifiedOnBehalfBy = mobb_sub.SystemUserId
LEFT JOIN EdwStage.dbo.CRM_SystemUserBase mb_sub ON opp.ModifiedBy = mb_sub.SystemUserId
LEFT JOIN EdwStage.dbo.CRM_CampaignBase sc2 ON opp.po_sourcecampaign2 = sc2.CampaignId
LEFT JOIN EdwStage.dbo.CRM_CampaignBase sc3 ON opp.po_sourcecampaign3 = sc3.CampaignId

-- Additional Joins (Added from JT)
LEFT JOIN EdwStage.dbo.LeadBase lead ON opp.OriginatingLeadId = lead.LeadId
LEFT JOIN EdwStage.dbo.CRM_po_addressBase baddr ON opp.po_BillingAddress = baddr.po_addressId
LEFT JOIN EdwStage.dbo.CRM_po_addressBase saddr ON opp.po_ShiptoAddress = saddr.po_addressId
LEFT JOIN EdwStage.dbo.TransactionCurrencyBase t ON t.TransactionCurrencyId = opp.TransactionCurrencyId
LEFT JOIN EdwStage.dbo.CRM_SystemUserBase eauser ON opp.po_EnterpriseArchitect = eauser.SystemUserId
LEFT JOIN EdwStage.dbo.CRM_SystemUserBase isruser ON opp.po_ISR = isruser.SystemUserId
LEFT JOIN EdwStage.dbo.CRM_SystemUserBase leaduser ON opp.po_LeadGenerator = leaduser.SystemUserId
LEFT JOIN EdwStage.dbo.CRM_SystemUserBase masr ON opp.po_MASR = masr.SystemUserId
LEFT JOIN EdwStage.dbo.CRM_SystemUserBase owmgr ON opp.po_OpportunityOwnerManager = owmgr.SystemUserId
LEFT JOIN EdwStage.dbo.CRM_SystemUserBase rsm ON opp.po_RSM = rsm.SystemUserId
LEFT JOIN EdwStage.dbo.CRM_SystemUserBase crsm ON opp.po_RSM_Critical = crsm.SystemUserId
LEFT JOIN EdwStage.dbo.CRM_SystemUserBase srsm ON opp.po_RSM_Strategic = srsm.SystemUserId
LEFT JOIN EdwStage.dbo.CRM_SystemUserBase trsm ON opp.po_RSM_Transactional = trsm.SystemUserId

-- CTE Joins (PROD + New JT CTEs)
LEFT JOIN cte_StateCode state_c ON opp.StateCode = state_c.AttributeValue
LEFT JOIN cte_StatusCode status_c ON opp.StatusCode = status_c.AttributeValue
LEFT JOIN cte_SalesStage stage_c ON opp.SalesStage = stage_c.AttributeValue
LEFT JOIN cte_SalesStageCode stagecode_c ON opp.SalesStageCode = stagecode_c.AttributeValue
LEFT JOIN cte_ChancesOfWinning cowc ON opp.po_Chancesofwinning = cowc.AttributeValue
LEFT JOIN cte_Forecasted fc ON opp.po_Forecasted = fc.AttributeValue
LEFT JOIN cte_LosttoCompetitorType lct ON opp.po_LosttoCompetitorType = lct.AttributeValue
LEFT JOIN cte_PaymentTerms pt ON opp.po_PaymentTerms = pt.AttributeValue
LEFT JOIN cte_QualifiesforIRSCredit qfic ON opp.po_QualifiesforIRSCredit = qfic.AttributeValue
LEFT JOIN cte_ReasonClosed rc ON opp.po_ReasonClosed = rc.AttributeValue
LEFT JOIN cte_SolutionApproved sa ON opp.po_SolutionApproved = sa.AttributeValue
LEFT JOIN cte_SolutionAssuranceRequired sar ON opp.po_SolutionAssuranceRequired = sar.AttributeValue
LEFT JOIN cte_SolutionFunded sf ON opp.po_SolutionFunded = sf.AttributeValue
LEFT JOIN cte_OpportunityType opt ON opp.po_OpportunityType = opt.AttributeValue
LEFT JOIN cte_QuickCreate qc ON opp.po_QuickCreate = qc.AttributeValue
LEFT JOIN cte_CopyOpportunity cop ON opp.po_CopyOpportunity = cop.AttributeValue
LEFT JOIN cte_SuperTerritory st ON tb.po_SuperTerritory = st.AttributeValue
LEFT JOIN cte_Zone z ON tb.po_Zone = z.AttributeValue
LEFT JOIN cte_WinLossStatus wls ON opp.po_WinLossStatus = wls.AttributeValue
LEFT JOIN cte_ExpiredOpp eop ON opp.po_ExpiredOpp = eop.AttributeValue
LEFT JOIN cte_CloudMSSalesStage cmss ON opp.po_CloudMSSalesStage = cmss.AttributeValue
LEFT JOIN cte_DedicatedTech dt ON opp.po_DedicatedTech = dt.AttributeValue
LEFT JOIN cte_PrimaryCSCSupport pcsc ON opp.po_PrimaryCSCSupport = pcsc.AttributeValue
LEFT JOIN cte_OpLinkedToAccountPlan olta ON opp.po_OpLinkedToAccountPlan = olta.AttributeValue
LEFT JOIN cte_Probability prob ON opp.po_Probability = prob.AttributeValue
LEFT JOIN cte_ReasonLost rl ON opp.po_ReasonLost = rl.AttributeValue
LEFT JOIN cte_Upside cu ON opp.po_Upside = cu.AttributeValue
LEFT JOIN cte_CampaignType cpt1 ON cmpb.TypeCode = cpt1.AttributeValue
LEFT JOIN cte_CampaignType cpt2 ON sc2.TypeCode = cpt2.AttributeValue
LEFT JOIN cte_CampaignType cpt3 ON sc3.TypeCode = cpt3.AttributeValue
LEFT JOIN cte_RVPBridgeOpportunity rvp on opp.po_RVPBridgeOpportunity = rvp.AttributeValue

-- New CTE Joins (From JT)
LEFT JOIN cte_BudgetStatus ON opp.BudgetStatus = cte_BudgetStatus.AttributeValue
LEFT JOIN cte_CaptureProposalFeedback ON opp.CaptureProposalFeedback = cte_CaptureProposalFeedback.AttributeValue
LEFT JOIN cte_new_GEMS ON opp.new_GEMS = cte_new_GEMS.AttributeValue
LEFT JOIN cte_po_AutoCreated ON opp.po_AutoCreated = cte_po_AutoCreated.AttributeValue
LEFT JOIN cte_po_AutoRoundUp ON opp.po_AutoRoundUp = cte_po_AutoRoundUp.AttributeValue
LEFT JOIN cte_po_ECommerce ON opp.po_ECommerce = cte_po_ECommerce.AttributeValue
LEFT JOIN cte_po_LCPRateCardEnabled ON opp.po_LCPRateCardEnabled = cte_po_LCPRateCardEnabled.AttributeValue
LEFT JOIN cte_po_LeadGeneratorRole ON opp.po_LeadGeneratorRole = cte_po_LeadGeneratorRole.AttributeValue
LEFT JOIN cte_po_Lease ON opp.po_Lease = cte_po_Lease.AttributeValue
LEFT JOIN cte_po_LiftShiftReason ON opp.po_LiftShiftReason = cte_po_LiftShiftReason.AttributeValue
LEFT JOIN cte_po_LostSubReason ON opp.po_LostSubReason = cte_po_LostSubReason.AttributeValue
LEFT JOIN cte_po_NoRounding ON opp.po_NoRounding = cte_po_NoRounding.AttributeValue
LEFT JOIN cte_po_OPidentifiedthroughWAVESorAdvisory ON opp.po_OPidentifiedthroughWAVESorAdvisory = cte_po_OPidentifiedthroughWAVESorAdvisory.AttributeValue
LEFT JOIN cte_po_OpportunityCategory ON opp.po_OpportunityCategory = cte_po_OpportunityCategory.AttributeValue
LEFT JOIN cte_po_OpportunityIdentifiedThrough ON opp.po_OpportunityIdentifiedThrough = cte_po_OpportunityIdentifiedThrough.AttributeValue
LEFT JOIN cte_po_QuotesComplete ON opp.po_QuotesComplete = cte_po_QuotesComplete.AttributeValue
LEFT JOIN cte_po_SalesPlay ON opp.po_SalesPlay = cte_po_SalesPlay.AttributeValue
LEFT JOIN cte_po_ShiptoInstallAddress ON opp.po_ShiptoInstallAddress = cte_po_ShiptoInstallAddress.AttributeValue
LEFT JOIN cte_po_ShiptoPRC ON opp.po_ShiptoPRC = cte_po_ShiptoPRC.AttributeValue
LEFT JOIN cte_po_SoldasManagedServices ON opp.po_SoldasManagedServices = cte_po_SoldasManagedServices.AttributeValue
LEFT JOIN cte_PricingErrorCode ON opp.PricingErrorCode = cte_PricingErrorCode.AttributeValue
LEFT JOIN cte_PriorityCode ON opp.PriorityCode = cte_PriorityCode.AttributeValue
LEFT JOIN cte_PurchaseProcess ON opp.PurchaseProcess = cte_PurchaseProcess.AttributeValue
LEFT JOIN cte_PurchaseTimeframe ON opp.PurchaseTimeframe = cte_PurchaseTimeframe.AttributeValue
LEFT JOIN cte_PursuitDecision ON opp.PursuitDecision = cte_PursuitDecision.AttributeValue
LEFT JOIN cte_ResolveFeedback ON opp.ResolveFeedback = cte_ResolveFeedback.AttributeValue

-- Sales Potential Subquery (From PROD)
LEFT JOIN (
    SELECT
      spb.po_Opportunity
    , SUM(CASE WHEN rcb.po_name = 'Hardware-New' THEN ISNULL(spb.po_ExtTotalCost,0.00) ELSE 0.00 END) AS HardwareNewEstimatedCost
    , SUM(CASE WHEN rcb.po_name = 'Hardware-New' THEN ISNULL(spb.po_EstimatedRevenue,0.00) ELSE 0.00 END) AS HardwareNewEstimatedRevenue
    , SUM(CASE WHEN rcb.po_name = 'Hardware-Refurb' THEN ISNULL(spb.po_ExtTotalCost,0.00) ELSE 0.00 END) AS HardwareRefurbEstimatedCost
    , SUM(CASE WHEN rcb.po_name = 'Hardware-Refurb' THEN ISNULL(spb.po_EstimatedRevenue,0.00) ELSE 0.00 END) AS HardwareRefurbEstimatedRevenue
    , SUM(CASE WHEN rcb.po_name = 'Maintenance-InHouse' THEN ISNULL(spb.po_ExtTotalCost,0.00) ELSE 0.00 END) AS MaintenanceInHouseEstimatedCost
    , SUM(CASE WHEN rcb.po_name = 'Maintenance-InHouse' THEN ISNULL(spb.po_EstimatedRevenue,0.00) ELSE 0.00 END) AS MaintenanceInHouseEstimatedRevenue
    , SUM(CASE WHEN rcb.po_name = 'Maintenance-Resale' THEN ISNULL(spb.po_ExtTotalCost,0.00) ELSE 0.00 END) AS MaintenanceResaleEstimatedCost
    , SUM(CASE WHEN rcb.po_name = 'Maintenance-Resale' THEN ISNULL(spb.po_EstimatedRevenue,0.00) ELSE 0.00 END) AS MaintenanceResaleEstimatedRevenue
    , SUM(CASE WHEN rcb.po_name = 'Managed Services' THEN ISNULL(spb.po_ExtTotalCost,0.00) ELSE 0.00 END) AS ManagedServicesEstimatedCost
    , SUM(CASE WHEN rcb.po_name = 'Managed Services' THEN ISNULL(spb.po_EstimatedRevenue,0.00) ELSE 0.00 END) AS ManagedServicesEstimatedRevenue
    , SUM(CASE WHEN rcb.po_name = 'Professional Services' THEN ISNULL(spb.po_ExtTotalCost,0.00) ELSE 0.00 END) AS ProfessionalServicesEstimatedCost
    , SUM(CASE WHEN rcb.po_name = 'Professional Services' THEN ISNULL(spb.po_EstimatedRevenue,0.00) ELSE 0.00 END) AS ProfessionalServicesEstimatedRevenue
    , SUM(CASE WHEN rcb.po_name = 'Software' THEN ISNULL(spb.po_ExtTotalCost,0.00) ELSE 0.00 END) AS SoftwareEstimatedCost
    , SUM(CASE WHEN rcb.po_name = 'Software' THEN ISNULL(spb.po_EstimatedRevenue,0.00) ELSE 0.00 END) AS SoftwareNewEstimatedRevenue
    , SUM(ISNULL(spb.po_ExtTotalCost,0.00)) AS TotalEstimatedCost
    , SUM(ISNULL(spb.po_EstimatedRevenue,0.00)) AS TotalEstimatedRevenue
    FROM EdwStage.dbo.CRM_po_salespotentialBase spb
    JOIN cte_SPBStateCode spb_state_c ON spb.statecode = spb_state_c.AttributeValue
        AND spb_state_c.[Value] <> 'Inactive'
    JOIN cte_SPBStatusCode spb_status_c ON spb.statuscode = spb_status_c.AttributeValue
        AND spb_status_c.[Value] <> 'Inactive'
    JOIN EdwStage.dbo.CRM_po_revenuecategoryBase rcb ON spb.po_RevenueCategory = rcb.po_revenuecategoryId
    GROUP BY spb.po_Opportunity
) spbrc ON opp.OpportunityId = spbrc.po_Opportunity

WHERE ISNULL(change.SYS_CHANGE_OPERATION,'I') IN ('U','I')

;
GO