**VARS TO REPLACE IN TEMPLATE:**

** REMOVE THIS SECTION BEFORE PUBLISHING**

- `Onboarding`: the application name
- `<APP_PORT>`: app running port
- `cozy-onboarding-v3`: transifex app slug
- `cozy-onboarding-v3`: Github repository slugname

---

[![Travis build status shield](https://img.shields.io/travis/cozy/cozy-onboarding-v3/master.svg)](https://travis-ci.org/cozy/cozy-onboarding-v3)
[![Github Release version shield](https://img.shields.io/github/tag/cozy/cozy-onboarding-v3.svg)](https://github.com/cozy/cozy-onboarding-v3/releases)


[Cozy] Onboarding
=======================


What's Cozy?
------------

![Cozy Logo](https://cdn.rawgit.com/cozy/cozy-guidelines/master/templates/cozy_logo_small.svg)

[Cozy] is a platform that brings all your web services in the same private space.  With it, your webapps and your devices can share data easily, providing you with a new experience. You can install Cozy on your own hardware where no one's tracking you.


What's Onboarding?
------------------

Cozy Onboarding helps users to register and configure their cozy the first time they access to it.


## Hack

To be hacked, the Cozy Proxy dev environment requires that a CouchDB instance
and a Cozy Data System instance are running. Then you can start the Cozy Proxy
this way:

```sh
$ git clone https://github.com/cozy/cozy-onboarding-v3.git
$ cd cozy-onboarding-v3
$ npm install
$ npm run watch
```

### To hack cozy-onboarding-v3 using the cozy vagrant

- Forward cozy-home application port from the virtual machine: `config.vm.network :forwarded_port, guest: 9103, host: 9103` in file Vagrantfile
  (if the virtual machine is already up, you can apply this change with `vagrant reload`)
- On your computer, go to your cozy-onboarding-v3 folder `cd your-cozy-onboarding-v3-folder`
- Run `npm install`
- Once install is done, launch cozy-onboarding-v3 `PORT=9555 HOST="0.0.0.0" npm run watch` (You may use another port)
- You can now access the hacked proxy on `http://localhost:9555` with your navigator

#### Note about Cozy-ui

[Cozy-ui] is our frontend stack library that provides common styles and components accross the whole Cozy's apps. You can use it for you own application to follow the official Cozy's guidelines and styles. If you need to develop / hack cozy-ui, it's sometimes more useful to develop on it through another app. You can do it by cloning cozy-ui locally and link it to yarn local index:

```sh
git clone https://github.com/cozy/cozy-ui.git
cd cozy-ui
yarn link
```

then go back to your app project and replace the distributed cozy-ui module with the linked one:

```sh
cd cozy-onboarding-v3
yarn link cozy-ui
```

You can now run the watch task and your project will hot-reload each times a cozy-ui source file is touched.


### Run it inside the VM

You can easily view your current running app in your VM, use [cozy-dev]:

```sh
# in a terminal, run your app in watch mode
$ cd cozy-onboarding-v3
$ yarn run watch
```

```sh
# in another terminal, install cozy-dev (first time) and run the deploy
$ cd cozy-onboarding-v3
$ yarn global install cozy-dev
$ cozy-dev deploy <APP_PORT>
```

your app is available in your vm dashboard at http://localhost:9104.


### Tests

Tests are run by [mocha] under the hood, and written using [chai] and [sinon]. You can easily run the tests suite with:

```sh
$ cd cozy-onboarding-v3
$ yarn test
```

:pushpin: Don't forget to update / create new tests when you contribute to code to keep the app the consistent.


## Models

The Cozy datastore stores documents, which can be seen as JSON objects. A `doctype` is simply a declaration of the fields in a given JSON object, to store similar objects in an homogeneous fashion.

Cozy ships a [built-in list of `doctypes`][doctypes] for representation of most of the common documents (Bills, Contacts, Events, ...).

Whenever your app needs to use a given `doctype`, you should:

- Check if this is a standard `doctype` defined in Cozy itself. If this is the case, you should add a model declaration in your app containing at least the fields listed in the [main fields list for this `doctype`][doctypes]. Note that you can extend the Cozy-provided `doctype` with your own customs fields. This is typically what is done in [Konnectors] for the [Bill `doctype`][bill-doctype].
- If no standards `doctypes` fit your needs, you should define your own `doctype` in your app. In this case, you do not have to put any field you want in your model, but you should crosscheck other cozy apps to try to homogeneize the names of your fields, so that your `doctype` data could be reused by other apps. This is typically the case for the [Konnector `doctype`][konnector-doctype] in [Konnectors].


### Resources

All documentation is located in the `/docs` app directory. It provides an exhaustive documentation about workflows (installation, development, pull-requests…), architecture, code consistency, data structures, dependencies, and more.

Feel free to read it and fix / update it if needed, all comments and feedback to improve it are welcome!


### Open a Pull-Request

If you want to work on Onboarding and submit code modifications, feel free to open pull-requests! See the [contributing guide][contribute] for more information about how to properly open pull-requests.


Community
---------

### Localization

Localization and translations are handled by [Transifex][tx], which is used by all Cozy's apps.

As a _translator_, you can login to [Transifex][tx-signin] (using your Github account) and claim an access to the [app repository][tx-app]. Locales are pulled when app is build before publishing.

As a _developer_, you must [configure the transifex client][tx-client], and claim an access as _maintainer_ is the [app repository][tx-app]. Then please **only update** the source locale file (usually `en.json` in client and/or server parts), and push it to Transifex repository using the `tx push -s` command.


### Get in touch

You can reach the Cozy Community by:

- Chatting with us on IRC [#cozycloud on Freenode][freenode]
- Posting on our [Forum][forum]
- Posting issues on the [Github repos][github]
- Say Hi! on [Twitter][twitter]


License
-------

Cozy Onboarding is developed by Cozy Cloud and distributed under the [AGPL v3 license][agpl-3.0].



[cozy]: https://cozy.io "Cozy Cloud"
[setup]: https://dev.cozy.io/#set-up-the-development-environment "Cozy dev docs: Set up the Development Environment"
[yarn]: https://yarnpkg.com/
[yarn-install]: https://yarnpkg.com/en/docs/install
[cozy-ui]: https://github.com/cozy/cozy-ui
[doctypes]: https://dev.cozy.io/#main-document-types
[bill-doctype]: https://github.com/cozy-labs/konnectors/blob/master/server/models/bill.coffee
[konnector-doctype]: https://github.com/cozy-labs/konnectors/blob/master/server/models/konnector.coffee
[konnectors]: https://github.com/cozy-labs/konnectors
[agpl-3.0]: https://www.gnu.org/licenses/agpl-3.0.html
[contribute]: CONTRIBUTING.md
[tx]: https://www.transifex.com/cozy/
[tx-signin]: https://www.transifex.com/signin/
[tx-app]: https://www.transifex.com/cozy/cozy-onboarding-v3/dashboard/
[tx-client]: http://docs.transifex.com/client/
[freenode]: http://webchat.freenode.net/?randomnick=1&channels=%23cozycloud&uio=d4
[forum]: https://forum.cozy.io/
[github]: https://github.com/cozy/
[twitter]: https://twitter.com/mycozycloud
[nvm]: https://github.com/creationix/nvm
[ndenv]: https://github.com/riywo/ndenv
[cozy-dev]: https://github.com/cozy/cozy-dev/
[mocha]: https://mochajs.org/
[chai]: http://chaijs.com/
[sinon]: http://sinonjs.org/
[checkbox]: https://help.github.com/articles/basic-writing-and-formatting-syntax/#task-lists
