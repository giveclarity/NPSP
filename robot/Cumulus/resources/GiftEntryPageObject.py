import time
from cumulusci.robotframework.utils import capture_screenshot_on_error
from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import pageobject
from BaseObjects import BaseNPSPPage
from NPSP import npsp_lex_locators
from logging import exception

@pageobject("Landing", "GE_Gift_Entry")
class GiftEntryLandingPage(BaseNPSPPage, BasePage):

    
    def _go_to_page(self, filter_name=None):
        """To go to Gift Entry page"""
        url_template = "{root}/lightning/n/{object}"
        name = self._object_name
        object_name = "{}{}".format(self.cumulusci.get_namespace_prefix(), name)
        url = url_template.format(root=self.cumulusci.org.lightning_base_url, object=object_name)
        self.selenium.go_to(url)
        self.salesforce.wait_until_loading_is_complete()
        self.selenium.wait_until_page_contains("Templates")

    def _is_current_page(self):
        """
        Verifies that current page is Gift Entry landing page
        """
        self.selenium.wait_until_location_contains("GE_Gift_Entry", timeout=60, 
                                                   message="Current page is not Gift Entry landing page")
        self.selenium.wait_until_page_contains("Default Gift Entry Template")                                               

    def click_gift_entry_button(self,title):
        """clicks on Gift Entry button identified with title"""
        locator=npsp_lex_locators["gift_entry"]["button"].format(title)
        self.selenium.wait_until_page_contains_element(locator)
        self.selenium.click_element(locator)  

    def select_template_action(self,name,action):
        """From the template table, select template with name and select an action from the dropdown"""
        locator=npsp_lex_locators["gift_entry"]["actions_dropdown"].format(name)
        self.selenium.click_element(locator)
        element=self.selenium.get_webelement(locator)
        status=element.get_attribute("aria-expanded")
        if status=="false":
            self.selenium.wait_until_page_contains("Clone")    
        self.selenium.click_link(action)
        if action=="Edit" or action=="Clone":
            self.selenium.wait_until_page_contains("Gift Entry Template Information")
        elif action=="Delete":
            self.selenium.wait_until_page_does_not_contain(name)     


@pageobject("Template", "GE_Gift_Entry")
class GiftEntryTemplatePage(BaseNPSPPage, BasePage):


    def _is_current_page(self):
        """
        Verifies that current page is Template Builder edit page
        """
        self.selenium.wait_until_page_contains("Gift Entry Template Information")       
    
    def enter_value_in_field(self,**kwargs):
        """Enter value in specified field"""
        for key,value in kwargs.items():
            if key=='Description':
                locator=npsp_lex_locators["gift_entry"]["field_input"].format(key,"textarea")
                self.selenium.wait_until_page_contains_element(locator)
                self.salesforce._populate_field(locator, value)
            else:
                locator=npsp_lex_locators["gift_entry"]["field_input"].format(key,"input")
                self.selenium.wait_until_page_contains_element(locator)
                self.salesforce._populate_field(locator, value)   

    def select_object_group_field(self,object_group,field):
        """Select the specified field under specified object group 
           to add the field to gift entry form and verify field is added"""
        locator=npsp_lex_locators["gift_entry"]["form_object_dropdown"].format(object_group)
        self.selenium.scroll_element_into_view(locator)
        self.selenium.click_element(locator)
        element=self.selenium.get_webelement(locator)
        status=element.get_attribute("aria-expanded")
        if status=="false":
            time.sleep(2)       
        field_checkbox=npsp_lex_locators["gift_entry"]["checkbox"].format(field)  
        self.selenium.scroll_element_into_view(field_checkbox)   
        self.selenium.click_element(field_checkbox)
        field_label=object_group+': '+field
        self.selenium.wait_until_page_contains(field_label)

    def fill_gift_entry_form(self,**kwargs):
        """"""
        for key,value in kwargs.items():
            if value=='checked':
                field_checkbox=npsp_lex_locators["gift_entry"]["checkbox"].format(key)
                self.selenium.select_checkbox(field_checkbox)
            elif value=='unchecked': 
                field_checkbox=npsp_lex_locators["gift_entry"]["checkbox"].format(key)
                self.selenium.unselect_checkbox(field_checkbox)   
            elif "Date" in key:
                field_loc=npsp_lex_locators["gift_entry"]["field_input"].format(key,"input")
                self.selenium.click_element(field_loc)
                locator=npsp_lex_locators["bge"]["datepicker_open"].format(field)  
                self.selenium.wait_until_page_contains_element(locator)
                self.selenium.click_button(value)    
                self.selenium.wait_until_page_does_not_contain_element(locator,error="could not open datepicker")
            else:
                loc=npsp_lex_locators["gift_entry"]["field_input"].format(key,"input")   
                self.selenium.click_element(loc) 
                popup=npsp_lex_locators["flexipage-popup"]
                if popup:
                    
                


