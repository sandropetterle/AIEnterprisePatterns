// monitoring.bicep — Application Insights + Log Analytics + 4 metric alerts
// No dependencies on other modules. Deploy first.

@description('Azure region for all resources')
param location string

@description('Environment name suffix (e.g. prod)')
param environment string = 'prod'

// ── Log Analytics Workspace ───────────────────────────────────────────────────

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'log-aipatterns-${environment}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// ── Application Insights ──────────────────────────────────────────────────────

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-aipatterns-${environment}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    IngestionMode: 'LogAnalytics'
    RetentionInDays: 30
  }
}

// ── Metric Alerts ─────────────────────────────────────────────────────────────

resource alertErrorRate 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-aipatterns-error-rate-${environment}'
  location: 'global'
  properties: {
    description: 'Alert when server error rate exceeds 5%'
    severity: 2
    enabled: true
    scopes: [appInsights.id]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'HighErrorRate'
          metricName: 'requests/failed'
          operator: 'GreaterThan'
          threshold: 10
          timeAggregation: 'Count'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    autoMitigate: true
  }
}

resource alertResponseTime 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-aipatterns-response-time-${environment}'
  location: 'global'
  properties: {
    description: 'Alert when average response time exceeds 3 seconds'
    severity: 2
    enabled: true
    scopes: [appInsights.id]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'SlowResponseTime'
          metricName: 'requests/duration'
          operator: 'GreaterThan'
          threshold: 3000
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    autoMitigate: true
  }
}

resource alertAvailability 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-aipatterns-availability-${environment}'
  location: 'global'
  properties: {
    description: 'Alert when availability drops below 95%'
    severity: 1
    enabled: true
    scopes: [appInsights.id]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'LowAvailability'
          metricName: 'availabilityResults/availabilityPercentage'
          operator: 'LessThan'
          threshold: 95
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    autoMitigate: true
  }
}

resource alertExceptionSpike 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-aipatterns-exception-spike-${environment}'
  location: 'global'
  properties: {
    description: 'Alert on sharp increase in exception rate'
    severity: 2
    enabled: true
    scopes: [appInsights.id]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'ExceptionSpike'
          metricName: 'exceptions/count'
          operator: 'GreaterThan'
          threshold: 20
          timeAggregation: 'Count'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    autoMitigate: true
  }
}

// ── Outputs ───────────────────────────────────────────────────────────────────

@description('Log Analytics workspace resource ID (for Container Apps Environment)')
output logAnalyticsId string = logAnalytics.id

@description('Log Analytics workspace customer ID (for Container Apps Environment)')
output logAnalyticsCustomerId string = logAnalytics.properties.customerId

@description('Application Insights connection string (passed to Container Apps as env var)')
output appInsightsConnectionString string = appInsights.properties.ConnectionString
