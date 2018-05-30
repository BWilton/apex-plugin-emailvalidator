set define off
set verify off
set feedback off
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
begin wwv_flow.g_import_in_progress := true; end; 
/
 
--       AAAA       PPPPP   EEEEEE  XX      XX
--      AA  AA      PP  PP  EE       XX    XX
--     AA    AA     PP  PP  EE        XX  XX
--    AAAAAAAAAA    PPPPP   EEEE       XXXX
--   AA        AA   PP      EE        XX  XX
--  AA          AA  PP      EE       XX    XX
--  AA          AA  PP      EEEEEE  XX      XX
prompt  Set Credentials...
 
begin
 
  -- Assumes you are running the script connected to SQL*Plus as the Oracle user APEX_040100 or as the owner (parsing schema) of the application.
  wwv_flow_api.set_security_group_id(p_security_group_id=>nvl(wwv_flow_application_install.get_workspace_id,5778004851557075));
 
end;
/

begin wwv_flow.g_import_in_progress := true; end;
/
begin 

select value into wwv_flow_api.g_nls_numeric_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';

end;

/
begin execute immediate 'alter session set nls_numeric_characters=''.,''';

end;

/
begin wwv_flow.g_browser_language := 'en'; end;
/
prompt  Check Compatibility...
 
begin
 
-- This date identifies the minimum version required to import this file.
wwv_flow_api.set_version(p_version_yyyy_mm_dd=>'2011.02.12');
 
end;
/

prompt  Set Application ID...
 
begin
 
   -- SET APPLICATION ID
   wwv_flow.g_flow_id := nvl(wwv_flow_application_install.get_application_id,117);
   wwv_flow_api.g_id_offset := nvl(wwv_flow_application_install.get_offset,0);
null;
 
end;
/

prompt  ...plugins
--
--application/shared_components/plugins/item_type/co_nz_chromacode_emailvalidator
 
begin
 
wwv_flow_api.create_plugin (
  p_id => 3605928557872955659 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_type => 'ITEM TYPE'
 ,p_name => 'CO.NZ.CHROMACODE.EMAILVALIDATOR'
 ,p_display_name => 'Email Validator'
 ,p_image_prefix => '#PLUGIN_PREFIX#'
 ,p_plsql_code => 
'FUNCTION render('||unistr('\000a')||
'    p_item                IN apex_plugin.t_page_item,'||unistr('\000a')||
'    p_plugin              IN apex_plugin.t_plugin,'||unistr('\000a')||
'    p_value               IN VARCHAR2,'||unistr('\000a')||
'    p_is_readonly         IN boolean,'||unistr('\000a')||
'    p_is_printer_friendly IN boolean )'||unistr('\000a')||
'  RETURN apex_plugin.t_page_item_render_result'||unistr('\000a')||
'IS'||unistr('\000a')||
'  l_result apex_plugin.t_page_item_render_result;'||unistr('\000a')||
'BEGIN'||unistr('\000a')||
'  htp.p(''<input type="text" name="''||apex_plugin.get_inp'||
'ut_name_for_page_item(TRUE) || ''" id="''||p_item.NAME||''" ''|| '' value="''||sys.htf.escape_sc(p_value)|| ''" size="''||p_item.element_width||''" ''|| p_item.element_attributes||''/>'');'||unistr('\000a')||
'  RETURN l_result;'||unistr('\000a')||
'END;'||unistr('\000a')||
'FUNCTION validate_email_address('||unistr('\000a')||
'    p_item   IN apex_plugin.t_page_item,'||unistr('\000a')||
'    p_plugin IN apex_plugin.t_plugin,'||unistr('\000a')||
'    p_value  IN VARCHAR2 )'||unistr('\000a')||
'  RETURN apex_plugin.t_page_item_validation_result'||unistr('\000a')||
'IS'||unistr('\000a')||
'  l_re'||
'sult apex_plugin.t_page_item_validation_result;'||unistr('\000a')||
'  l_single_address VARCHAR2(1) := nvl(p_item.attribute_01, ''Y'');'||unistr('\000a')||
'  l_bad_addresses  VARCHAR2(4000);'||unistr('\000a')||
'  l_email_regex varchar2(4000) := nvl(p_item.attribute_02, ''^[a-zA-Z0-9]{1}[a-zA-Z0-9\.\-]{1,}@[a-zA-Z0-9]{1}[a-zA-Z0-9\.\-]{1,}\.{1}[a-zA-Z]{2,4}$'');'||unistr('\000a')||
'BEGIN'||unistr('\000a')||
'  IF l_single_address = ''Y'' THEN --Restricted to single address'||unistr('\000a')||
'    IF NOT REGEXP_LIKE(p_value,'||
'l_email_regex) THEN'||unistr('\000a')||
'      l_result.message := ''#LABEL# contains an invalid email address or too many addresses''||''<br>"''||p_value||''"<br>'';'||unistr('\000a')||
'    END IF;'||unistr('\000a')||
'  ELSE --multi address'||unistr('\000a')||
'    FOR i IN'||unistr('\000a')||
'    (SELECT regexp_substr(p_value,''[^,]+'',1,LEVEL) address'||unistr('\000a')||
'    FROM dual'||unistr('\000a')||
'      CONNECT BY regexp_substr(p_value,''[^,]+'',1,LEVEL) IS NOT NULL'||unistr('\000a')||
'    )'||unistr('\000a')||
'    loop'||unistr('\000a')||
'      IF NOT REGEXP_LIKE(i.address,l_email_regex) THEN'||unistr('\000a')||
' '||
'       --create a list of bad addresses'||unistr('\000a')||
'        l_bad_addresses := l_bad_addresses||''<br>"''||i.address||''"'';'||unistr('\000a')||
'      END IF;'||unistr('\000a')||
'    END loop;'||unistr('\000a')||
'    IF l_bad_addresses IS NOT NULL THEN'||unistr('\000a')||
'      l_result.message := ''#LABEL# contains an invalid email address''||l_bad_addresses||''<br>'';'||unistr('\000a')||
'    END IF;'||unistr('\000a')||
'  END IF;'||unistr('\000a')||
'  RETURN l_result;'||unistr('\000a')||
'END validate_email_address;'||unistr('\000a')||
''
 ,p_render_function => 'render'
 ,p_validation_function => 'validate_email_address'
 ,p_standard_attributes => 'VISIBLE:SESSION_STATE:READONLY:SOURCE:ELEMENT:WIDTH'
 ,p_substitute_attributes => true
 ,p_version_identifier => '0.1'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 3606590044505804946 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 3605928557872955659 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 1
 ,p_display_sequence => 10
 ,p_prompt => 'Restrict to one address'
 ,p_attribute_type => 'CHECKBOX'
 ,p_is_required => false
 ,p_default_value => 'Y'
 ,p_is_translatable => false
 ,p_help_text => 'Restricting to one address will return an error if the field contains more than one address, else each address will be validated.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 2405498844805493681 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 3605928557872955659 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 2
 ,p_display_sequence => 20
 ,p_prompt => 'Email Regex Pattern'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_display_length => 80
 ,p_is_translatable => false
 ,p_help_text => 'By default the plugin will match against a standard pattern. If you want to use your own then add it here.'||unistr('\000a')||
'The default is '||unistr('\000a')||
'^[a-zA-Z0-9]{1}[a-zA-Z0-9\.\-]{1,}@[a-zA-Z0-9]{1}[a-zA-Z0-9\.\-]{1,}\.{1}[a-zA-Z]{2,4}$'
  );
null;
 
end;
/

commit;
begin 
execute immediate 'begin dbms_session.set_nls( param => ''NLS_NUMERIC_CHARACTERS'', value => '''''''' || replace(wwv_flow_api.g_nls_numeric_chars,'''''''','''''''''''') || ''''''''); end;';
end;
/
set verify on
set feedback on
prompt  ...done
