<%@taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<script type="text/javascript" charset="utf-8">
    function findAllUsers(){
       $('#user_list').dataTable({
      	  "destroy": true,
          "bProcessing": true,
          "bServerSide": true,
          "sPaginationType": "full_numbers",
          "sAjaxDataProp": "rows",
          "aoColumns": [
              {"mData": "username"}, 
              {"mData": "firstname"},
              {"mData": "lastname"},
              {"mData": "email"},
              {"sName": "Actions",
                 "bSearchable": false,
                 "bSortable": false,
                 "sDefaultContent": "",
                 "mRender":  function(data, type, full){
                    return "<a href='${pageContext.request.contextPath}/administration/user/update?id=" + full['id'] + "' class='btn btn-primary btn-xs'><i class='fa fa-folder'></i> <spring:message code='common.update' /> </a> "+
                           "<a href='${pageContext.request.contextPath}/administration/user/delete?id=" + full['id'] + "' class='btn btn-danger btn-xs'><i class='fa fa-trash'></i> <spring:message code='common.delete' /> </a>"+
                           "<a data-href='${pageContext.request.contextPath}/administration/user/expire/session?id=" + full['id'] + "' class='btn btn-warning btn-xs open-modal-expire-session'><i class='fa fa-sign-out'></i> <spring:message code='common.expire.session' /></a>";
                 }
             }
          ],
          "sAjaxSource": "${pageContext.request.contextPath}/administration/user/findallpaginated",
          "oLanguage": {"sUrl": "${pageContext.request.contextPath}/static/plugin_extension/datatables/i18n/datatables-${pageContext.response.locale}.properties"},
          "fnServerParams": addparams,
          "fnServerData": function ( sSource, aoData, fnCallback, oSettings ) {
             oSettings.jqXHR = $.ajax( {
               "dataType": 'json',
               "type": "POST",
               "url": sSource,
               "data": aoData,
               "success":  function (json) {
                  fnCallback(json.result);
               },
               "error": function (e) {
                   console.log(e.message);
               }
             });
           },
          "initComplete": function( settings, json ) {
             $(".open-modal-expire-session").on("click", function () {
                $(".modal-footer #expire-session").attr("href", $(this).data('href'));
                $("#modal-expire-session").modal('show');
          	 });
           }
      }).columnFilter({
         aoColumns: [{type: "text"},
            {type: "text"},
            {type: "text"},
            {type: "text"},
            null
        ]});
       
    }
    
    
    $(document).ready(function() {
       switch('${requestScope.view_type}') {
       case 'list': //manage the page user_list.jsp
          findAllUsers();
          
       	  if(${not empty param.success and param.success}) {
             showMessage("success", "<spring:message code='common.success' />", "<spring:message code='common.success.message' />");
      	  }
          
          break;
       case 'create':
          $("#user_form").parsley()
          break;
       case 'update':
          $("#user_form").parsley()
          break;
       case 'delete':
          $(":input[type='text']").each(function () { $(this).attr('disabled','disabled'); });
      	  $(":input[type='email']").each(function () { $(this).attr('disabled','disabled'); });
      	  $(":input[type='password']").each(function () { $(this).attr('disabled','disabled'); });
      	  $(":input[type='checkbox']").each(function () { $(this).attr('disabled','disabled'); });
          $("#roles").prop("disabled", true);
          break;
   		}
         
	});
   
</script>