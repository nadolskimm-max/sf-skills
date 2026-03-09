# LWC Patterns Reference

## Lightning Message Service (LMS)

### 1. Create Message Channel

```xml
<!-- force-app/main/default/messageChannels/Record_Selected.messageChannel-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<LightningMessageChannel xmlns="http://soap.sforce.com/2006/04/metadata">
    <masterLabel>Record Selected</masterLabel>
    <isExposed>true</isExposed>
    <description>Published when a record is selected in a list</description>
    <lightningMessageFields>
        <fieldName>recordId</fieldName>
        <description>The Id of the selected record</description>
    </lightningMessageFields>
</LightningMessageChannel>
```

### 2. Publisher Component

```javascript
import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import RECORD_SELECTED from '@salesforce/messageChannel/Record_Selected__c';

export default class ListComponent extends LightningElement {
    @wire(MessageContext) messageContext;

    handleSelect(event) {
        publish(this.messageContext, RECORD_SELECTED, {
            recordId: event.detail.row.Id
        });
    }
}
```

### 3. Subscriber Component

```javascript
import { LightningElement, wire } from 'lwc';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import RECORD_SELECTED from '@salesforce/messageChannel/Record_Selected__c';

export default class DetailComponent extends LightningElement {
    recordId;
    subscription = null;

    @wire(MessageContext) messageContext;

    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            RECORD_SELECTED,
            (message) => this.handleMessage(message)
        );
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage(message) {
        this.recordId = message.recordId;
    }
}
```

## Jest Test Patterns

### Basic Component Test

```javascript
import { createElement } from 'lwc';
import AccountList from 'c/accountList';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

jest.mock('@salesforce/apex/AccountController.getAccounts', () => ({
    default: jest.fn()
}), { virtual: true });

const MOCK_ACCOUNTS = [
    { Id: '001xx000003ABCDEF', Name: 'Acme', Industry: 'Technology' },
    { Id: '001xx000003ABCDEG', Name: 'Global', Industry: 'Finance' }
];

describe('c-account-list', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('displays accounts when data is returned', async () => {
        getAccounts.mockResolvedValue(MOCK_ACCOUNTS);
        const element = createElement('c-account-list', { is: AccountList });
        document.body.appendChild(element);

        await Promise.resolve();

        const datatable = element.shadowRoot.querySelector('lightning-datatable');
        expect(datatable).not.toBeNull();
        expect(datatable.data).toEqual(MOCK_ACCOUNTS);
    });

    it('shows error panel when fetch fails', async () => {
        getAccounts.mockRejectedValue(new Error('Network error'));
        const element = createElement('c-account-list', { is: AccountList });
        document.body.appendChild(element);

        await Promise.resolve();
        await Promise.resolve();

        const errorPanel = element.shadowRoot.querySelector('c-error-panel');
        expect(errorPanel).not.toBeNull();
    });
});
```

## Apex Controller Pattern

```apex
public with sharing class AccountController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [
            SELECT Id, Name, Industry, Phone
            FROM Account
            ORDER BY Name
            LIMIT 200
        ];
    }

    @AuraEnabled
    public static Account createAccount(String name, String industry) {
        Account acc = new Account(Name = name, Industry = industry);
        insert acc;
        return acc;
    }
}
```

## Navigation Patterns

```javascript
import { NavigationMixin } from 'lightning/navigation';

export default class MyComponent extends NavigationMixin(LightningElement) {
    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }

    navigateToList() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }
}
```

## Toast Notifications

```javascript
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

showSuccess(message) {
    this.dispatchEvent(new ShowToastEvent({
        title: 'Success',
        message: message,
        variant: 'success'
    }));
}

showError(error) {
    const message = error?.body?.message || error?.message || 'Unknown error';
    this.dispatchEvent(new ShowToastEvent({
        title: 'Error',
        message: message,
        variant: 'error',
        mode: 'sticky'
    }));
}
```

## Form Patterns

### lightning-record-edit-form

```html
<template>
    <lightning-record-edit-form
        object-api-name="Contact"
        onsuccess={handleSuccess}
        onerror={handleError}>
        <lightning-messages></lightning-messages>
        <lightning-input-field field-name="FirstName"></lightning-input-field>
        <lightning-input-field field-name="LastName"></lightning-input-field>
        <lightning-input-field field-name="Email"></lightning-input-field>
        <lightning-button
            variant="brand"
            type="submit"
            label="Save">
        </lightning-button>
    </lightning-record-edit-form>
</template>
```
