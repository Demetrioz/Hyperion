enum ServiceEvent { initialize, subscribe, notificationReceived }

final Map<ServiceEvent, String> kServiceEvents = {
  ServiceEvent.initialize: 'initialize',
  ServiceEvent.subscribe: 'subscribe',
  ServiceEvent.notificationReceived: 'notification.received',
};
