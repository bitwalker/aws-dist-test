# Services

This application contains the core behaviours and processes for building and
interacting with registered services in the platform. Functionality includes:

- Behaviours which define the contracts for the various services
- Service registration
- Service discovery

The purpose of this app is to facilitate code which needs to consume services
provided between applications, when: 

- Those applications may need to be split up and run on different hosts
- Only one node in a cluster is allowed to run a particular service.
- Multiple nodes may run a service, and one needs to be selected

To avoid callers having to manage the details of communicating with a service,
whether the actual implementation is running on the same node, on another node
via Erlang distribution, or on another node via HTTP; services instead define
their API contract, and different implementations can be selected at runtime via configuration
