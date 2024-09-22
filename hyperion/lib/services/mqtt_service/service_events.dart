enum ServiceEvent { initialize, subscribe }

final Map<ServiceEvent, String> kServiceEvents = {
  ServiceEvent.initialize: 'initialize',
  ServiceEvent.subscribe: 'subscribe'
};
