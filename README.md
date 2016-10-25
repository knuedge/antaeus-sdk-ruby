The Antaeus SDK for Ruby
====================

About
----
Antaeus is a guest management system written by [KnuEdge](https://www.knuedge.com). The name comes from [a figure in Greek mythology](https://en.wikipedia.org/wiki/Antaeus) that would challenge travellers passing through his land to compete with him in a wrestling match. While this application has little to do with wrestling, it is used to track passers-by at [KnuEdge](https://www.knuedge.com) office locations.

This is the Ruby SDK designed to aid in and serve as a reference for interacting with the [Antaeus API](#). This SDK is certainly not required to use the API (everything could be done with `curl` calls or most any REST client), but it provides first-class Ruby objects to make things easy for a Ruby developer. It also happens to serve as the basis for the [Antaeus Web](#) application.

Building and Installing
----
Building the gem requires a modern Ruby:

    # highly recommend using RVM here, and Ruby 2.x or above
    gem build antaeus-sdk.gemspec
    # install what you just built
    gem install antaeus-sdk-*.gem

That said, recent releases should be available on [rubygems.org](https://rubygems.org/) so building is probably not necessary.

Just add the following to your Gemfile:

    gem 'antaeus-sdk', '~> 0.2'

Then run:

    bundle install

If you're not using [bundler](http://bundler.io/) for some reason (shame on you!), you can manually install like so:

    gem install antaeus-sdk

If you see a message like this:

    Thanks for installing the Antaeus Ruby SDK!

You should be all set!

Usage
------
Check back, because this file will be updated with a lot more usage examples.

For simplicity, this gem includes a CLI application for interacting with an API backend. To use it, run:

    $ antaeus-cli

It should be in your `PATH`. On the first run, it will create a directory called `~/.antaeus` (meaning it places it in your home directory), and it will drop a base configuration for the tool at `~/.antaeus/client.yml`. Edit this file, specifically changing `base_url`, `login`, and `password` as required. This document will be updated to show all configuration options available, along with their default values, in the future.

The CLI tool really is just a shortcut to the next few lines of boilerplate code to connect to the backend API and reuse configuration from a config file.

For a typical custom ruby application, you'll need to do something like the following to get started:

    require 'antaeus-sdk'
    
    # create an 'instance' of the User API Client Singleton
    client = Antaeus::UserAPIClient.instance
    # authenticate
    client.authenticate 'username', 'password'

From here, whether using the provided CLI tool or building a custom application, the instructions are the same.

First, connect the client to the API backend and obtain an API token:

    client.connect

You'll probably see something similar to the following:

    => #<RestClient::Resource:0x007fa693ecbbe8
     @block=nil,
     @options=
      {:content_type=>:json,
       :accept=>:json,
       :headers=>{:"X-API-Token:"=>"cv0qTNvJsTRMEn2jzLBvb+T25l6zc8feG3s62Q6XDPbB9isxG3gJ1wxRpyxINHgPRd9lu+afLrIzFj50KjLIFtPkGc5bOJKyO7BCCWFGY0erhbhFpXLJZg=="}},
     @url="https://antaeus.example.com">

This API client is built to be very flexible, working for both guest users (using the `GuestAPIClient`), typical users (using the `UserAPIClient` shown in this example), as well as for trusted front-end applications (using the same `UserAPIClient` in multi-user / impersonation mode). For this reason, Antaeus resources (subclasses of the `Antaeus::Resource` class) need to know which client to use to perform a given operation on the backend API. These resources are smart enough to keep using the same client, but a client (a sublcass of the `Antaeus::APIClient` class) must be provided to all class methods. For instance:

    # Retrieve a list of all Guests known to the system
    guests = Antaeus::Resources::Guest.all(client: client)

Note though, that any objects created using a class method with a client provided carry along that same client. This means that method chaining (for instance, on resource collections) is simple:

    # For simplicity, include the Antaeus::Resources module / namespace
    include Antaeus::Resources
    
    # Retrieve all guests with "gmail.com" in their email address
    guests = Guest.all(client: client).where(:email, /gmail\.com/, comparison: :match)
    # Or
    all_guests = Guest.all(client: client)
    guests = all_guests.where(:email, /gmail\.com/, comparison: :match)
    # Or even
    guests = Guest.where(:email, /gmail\.com/, comparison: :match, client: client)

The `#where()` is an instance method on the `Antaeus::ResourceCollection` class, which means that the searching is actually done locally. For small installations of Antaeus (or especially powerful client machines), this is likely the fastest way to do searching. That said, `Antaeus::Resource` also provides a `.search()` method that submits queries to the server for processing, returning only matching resources. This style of searching is less flexible, and may be slower for some operations given the lazy-loading of resource model data employed by this SDK.

The following resource classes (all under the `Antaeus::Resources` namespace) are available for typical API operations:

* `Appointment`
  * Used for creating, listing, and managing guest appointments
* `Group`
  * Read-only, used for listing and querying backend groups and their members. Only available to administrators and via the `UserAPIClient`
* `Guest`
  * Used for creating, listing, and managing guests.
* `Hook`
  * Used to configure plugins, targeting certain plugins at named system events. Only available to administrators and via the `UserAPIClient`
* `Location`
  * Used for creating, listing, and managing office locations. Read-only to non-administrators.
* `RemoteApplication`
  * Used for creating, listing, and managing remote front-end applications to the API. This is for very advanced cases only (such as integrating with different authentication systems). Only available to administrators and via the `UserAPIClient`
* `User`
  * Read-only, used for listing and querying backend users.

These do not correlate 1:1 with objects defined in the API, but they are a close and convenient approximation.

License
-------
This project and all code contained within it are released under the [MIT License](https://opensource.org/licenses/MIT). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> All contributions to this project will be released under the [MIT License](https://opensource.org/licenses/MIT). By submitting a pull request, you are agreeing to comply with this license and for any contributions to be released under it.
