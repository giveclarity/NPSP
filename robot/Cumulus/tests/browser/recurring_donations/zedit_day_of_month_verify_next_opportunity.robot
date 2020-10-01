*** Settings ***

Resource        robot/Cumulus/resources/NPSP.robot
Library         cumulusci.robotframework.PageObjects
...             robot/Cumulus/resources/NPSPSettingsPageObject.py
...             robot/Cumulus/resources/ContactPageObject.py
...             robot/Cumulus/resources/RecurringDonationsPageObject.py
...             robot/Cumulus/resources/OpportunityPageObject.py
Suite Setup     Run keywords
...             Enable RD2
...             Open Test Browser
...             Setup Test Data
Suite Teardown  Delete Records and Close Browser

*** Keywords ***

Setup Test Data
        [Documentation]     Data setup needed for the testcase. Creates a recurring
        ...                 donation of type open linked to a contact using backend API
        ${NS} =             Get NPSP Namespace Prefix
        Set Suite Variable  ${NS}

        #Create a Recurring Donation
        &{contact1_fields}=   Create Dictionary                     Email=rd2tester@example.com
        &{recurringdonation_fields} =	Create Dictionary           Name=ERD Open Recurring Donation
        ...                                                         npe03__Installment_Period__c=Yearly
        ...                                                         npe03__Amount__c=100
        ...                                                         npe03__Open_Ended_Status__c=Open
        ...                                                         npe03__Date_Established__c=2019-07-08
        ...                                                         ${NS}Status__c=Active
        ...                                                         ${NS}Day_of_Month__c=20
        ...                                                         ${NS}InstallmentFrequency__c=1
        ...                                                         ${NS}PaymentMethod__c=Check

        Setupdata   contact         ${contact1_fields}             recurringdonation_data=${recurringdonation_fields}
        ${CURRENT_DATE}=            Get current date               result_format=%-m/%-d/%Y
        Set Suite Variable          ${CURRENT_DATE}

Validate Opportunity Details
       [Documentation]         Navigate to opportunity details page of the specified
       ...                     opportunity and validate stage and Close date fields
       [Arguments]                       ${opportunityid}          ${stage}        ${date}
       Go To Page                              Details                        Opportunity                    object_id=${opportunityid}
       Current Page Should be                  Details                        Opportunity
       Navigate To And Validate Field Value    Stage                          contains                      ${stage}
       Navigate To And Validate Field Value    Close Date                     contains                      ${date}

Edit Opportunity Stage
       [Documentation]         Navigate to opportunity details page of the specified
       ...                     opportunity and update the opportunity stage detail
       [Arguments]                       ${opportunityid}          ${stage}
       Go To Page                              Details                        Opportunity                     object_id=${opportunityid}
       Wait Until Loading Is Complete
       Click Link                              link=Edit
       Wait until Modal Is Open
       Select Value From Dropdown              Stage                          ${stage}
       Click Modal Button                      Save


*** Test Cases ***

Edit Day Of Month For Enhanced Recurring donation record of type open
    [Documentation]               After creating an open recurring donation using API,
     ...                          The test ensures that there is only one opportunity.
     ...                          Closes the exisitng opportunity and verifies there is
     ...                          a new opportunity created. Edits the day of month on
     ...                          the recurring donation and verifies the closing dates
     ...                          for both the opportunities.


    [tags]                             unstable               W-040346            feature:RD2

    Go To Page                         Details
    ...                                npe03__Recurring_Donation__c
    ...                                object_id=${data}[contact_rd][Id]
    Wait Until Loading Is Complete
    Current Page Should be             Details    npe03__Recurring_Donation__c
    #Validate the number of opportunities on UI, Verify Opportinity got created in the backend
    Validate Related Record Count      Opportunities                                    1
    @{opportunities} =                 API Query Opportunity For Recurring Donation     ${data}[contact_rd][Id]
    Edit Opportunity Stage             ${opportunities}[0][Id]                          Closed Won
    Go To Page                         Details
    ...                                npe03__Recurring_Donation__c
    ...                                object_id=${data}[contact_rd][Id]
    Edit Recurring Donation Status
    ...                                Recurring Period=Monthly
    ...                                Day of Month=1
    Go To Page                         Details
    ...                                npe03__Recurring_Donation__c
    ...                                object_id=${data}[contact_rd][Id]
    Wait Until Loading Is Complete
    ${next_payment_date}               get next payment date number                    2

    #Validate that the number of opportunities now show as 2 .
    Validate Related Record Count      Opportunities                                   2
    @{opportunity} =                   API Query Opportunity For Recurring Donation                  ${data}[contact_rd][Id]
    #Verify the details on the respective opportunities
    Validate Opportunity Details       ${opportunity}[0][Id]        Closed Won                       ${CURRENT_DATE}
    Go To Page                         Details
    ...                                npe03__Recurring_Donation__c
    ...                                object_id=${data}[contact_rd][Id]
    Current Page Should be             Details    npe03__Recurring_Donation__c
    Wait Until Loading Is Complete
    Validate Opportunity Details       ${opportunity}[1][Id]        Pledged                          ${next_payment_date}