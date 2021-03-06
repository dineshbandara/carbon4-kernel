<!--
 ~ Copyright (c) 2005-2010, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 ~
 ~ WSO2 Inc. licenses this file to you under the Apache License,
 ~ Version 2.0 (the "License"); you may not use this file except
 ~ in compliance with the License.
 ~ You may obtain a copy of the License at
 ~
 ~    http://www.apache.org/licenses/LICENSE-2.0
 ~
 ~ Unless required by applicable law or agreed to in writing,
 ~ software distributed under the License is distributed on an
 ~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 ~ KIND, either express or implied.  See the License for the
 ~ specific language governing permissions and limitations
 ~ under the License.
 -->
<%@ page import="org.apache.axis2.context.ConfigurationContext" %>
<%@ page import="org.wso2.carbon.CarbonConstants" %>
<%@ page import="org.wso2.carbon.feature.mgt.ui.ProvisioningAdminClient" %>
<%@ page import="org.wso2.carbon.feature.mgt.stub.prov.data.FeatureInfo" %>
<%@ page import="org.wso2.carbon.feature.mgt.stub.prov.data.ProvisioningActionResultInfo" %>
<%@ page import="org.wso2.carbon.ui.CarbonUIUtil" %>
<%@ page import="org.wso2.carbon.utils.ServerConstants" %>
<%@ page import="org.wso2.carbon.ui.util.CharacterEncoder" %>
<%@ taglib uri="http://wso2.org/projects/carbon/taglibs/carbontags.jar" prefix="carbon" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    ProvisioningActionResultInfo uninstallActionResult = null;
    boolean proceedToNextStep;
    FeatureInfo[] features = null;
    String[] selectedFeatures = request.getParameterValues("selectedFeatures");
    String featurePropery = CharacterEncoder.getSafeText(request.getParameter("featurePropery"));
    String featureValue = CharacterEncoder.getSafeText(request.getParameter("featureValue"));

    String backendServerURL = CarbonUIUtil.getServerURL(config.getServletContext(), session);
    ConfigurationContext configContext =
            (ConfigurationContext) config.getServletContext().getAttribute(CarbonConstants.CONFIGURATION_CONTEXT);
    String cookie = (String) session.getAttribute(ServerConstants.ADMIN_SERVICE_COOKIE);
    ProvisioningAdminClient provAdminClient;

    if(selectedFeatures != null){
        features = new FeatureInfo[selectedFeatures.length];
        for(int index = 0; index < selectedFeatures.length; index++){
            String[] spliStrings = selectedFeatures[index].split("::");
            FeatureInfo feature = new FeatureInfo();
            feature.setFeatureID(spliStrings[0]);
            feature.setFeatureVersion(spliStrings[1]);
            features[index] = feature;
        }
    }

    try {
        provAdminClient = new ProvisioningAdminClient(cookie, backendServerURL, configContext, request.getLocale());
        if(selectedFeatures == null && featurePropery != null && featureValue != null ) {
            provAdminClient.removeAllFeaturesWithProperty(featurePropery, featureValue);
            return;
        }

        uninstallActionResult = provAdminClient.reviewUninstallFeaturesAction(features);
        if(uninstallActionResult == null)
            throw new Exception("Failed to review the Uninstallation plan");

        proceedToNextStep = uninstallActionResult.getProceedWithInstallation();
     } catch (Exception e) {
%>
<p id="compMgtErrorMsg"><%=e.getMessage()%></p>
<%
        return;
    }
%>
<fmt:bundle basename="org.wso2.carbon.feature.mgt.ui.i18n.Resources">
<table class="styledLeft" cellspacing="1" width="100%" id="_table_af_review_licenses_list"
           style="margin-left: 0px;">
    <thead>
        <tr>
            <th><H4><strong><fmt:message key="uninstall.details"/></strong></H4></th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>
                <table class="normal" cellspacing="1" width="100%" id="_table_add_repository_link"
                   style="margin-left: 0px;">
                    <tbody>
                        <tr><td><font color="#707277"><i><fmt:message key="unistall.details.description"/>.</i></font></td></tr>
                        <tr>
                            <td>
                                <table class="styledLeft" cellspacing="1" width="100%" id="_table_review_uninstall_features_list"
                                       style="margin-left: 0px;">
                                    <thead>
                                    <tr>
                                        <th><fmt:message key="name"/></th>
                                        <th><fmt:message key="version1"/></th>
                                        <th><fmt:message key="id"/></th>
                                        <th><fmt:message key="provider"/></th>
                                        <%--<th><fmt:message key="actions"/></th>--%>
                                    </tr>
                                    </thead>
                                    <tbody>

                                <%
                                    FeatureInfo[] reviewedFeatures = uninstallActionResult.getReviewedUninstallableFeatures();
                                    if(reviewedFeatures == null || reviewedFeatures.length == 0){
                                %>
                                        <tr>
                                            <td colspan="0"><fmt:message key="no.featurs.to.be.uninstalled"/>.</td>
                                        </tr>
                                <%
                                    } else {
                                        for(FeatureInfo feature: reviewedFeatures){
                                            String featureID = feature.getFeatureID();
                                            String featureVersion = feature.getFeatureVersion();
                                 %>
                                        <tr>
                                            <td><%=feature.getFeatureName()%></td>
                                            <td><%=featureVersion%></td>
                                            <td><%=featureID%></td>
                                            <td><%=feature.getProvider()%></td>
                                        </tr>
                                <%
                                        }
                                    }
                                %>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                        <%
                            String description = uninstallActionResult.getDetailedDescription();
                            if(description != null && !description.equals("")){
                        %>
                        <tr>
                            <td>
                                 <table class="styledLeft" cellspacing="1" width="100%" id="_table_review_uninstall_features_description"
                                   style="margin-left: 0px;">
                                    <thead>
                                    <tr>
                                        <th><fmt:message key="summary"/></th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <tr>
                                        <td><%=description%></td>
                                    </tr>
                                    </tbody>
                                </table>
                             </td>
                        </tr>
                    <%
                        }
                    %>

                    </tbody>
                </table>
            </td>
        </tr>
        <tr>
        <td class="buttonRow">
            <input value="<fmt:message key="next.button"/>" tabindex="11" type="button"
                   class="button"  onclick="doFinish('UF')"
                   <%=(proceedToNextStep)?"":"disabled='true'"%>
                   id="_btn_next_review_uninstall_features"/>
            <input value="<fmt:message key="cancel.button"/>" tabindex="11" type="button"
                   class="button"
                   onclick="doBack('RUF-IF')"
                   id="_btn_cancel_review_uninstall_features"/>
             <input id="_hidden_UF_actionType" value="<%=provAdminClient.getUninstallActionType()%>" type="hidden" />
        </td>
    </tr>
    </tbody>
</table>
</fmt:bundle>
<script type="text/javascript">
    alternateTableRows('_table_review_uninstall_features_list', 'tableEvenRow', 'tableOddRow');
</script>