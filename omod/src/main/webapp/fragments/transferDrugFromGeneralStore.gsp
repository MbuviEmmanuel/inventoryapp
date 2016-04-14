<style>
.dialog input {
    display: block;
    margin: 5px 0;
    color: #363463;
    padding: 5px 0 5px 10px;
    background-color: #FFF;
    border: 1px solid #DDD;
    width: 100%;
}

.dialog select option {
    font-size: 1em;
}

#modal-overlay {
    background: #000 none repeat scroll 0 0;
    opacity: 0.4 !important;
}

.dialog {
    display: none;
}

</style>
<script>
    var pDataString;
    jq(function () {


        jQuery('.date-pick').datepicker({minDate: '-100y', dateFormat: 'dd/mm/yy'});
        getIndentList();
		
		jq('#indentName').on('keyup paste',function(){
			reloadList();
		});

        //action when the searchField change occurs
        jq(".searchFieldChange").on("change", function () {
            reloadList();

        });

        //action when the searchField blur occurs
        jq(".searchFieldBlur").on("blur", function () {
            reloadList();
        });

        function reloadList(){
            var storeId = jq("#storeId").val();
            var statusId = jq("#statusId").val();
            var indentName = jq("#indentName").val();
            var fromDate = jq("#fromDate").val();
            var toDate=jq("#toDate").val();
            getIndentList(storeId, statusId, indentName, fromDate, toDate);
        }


    });//end of doc ready function
    function detailDrugIndent(indentId) {
//        prescriptionDialog.show();
        window.location.href = emr.pageLink("inventoryapp", "detailDrugIndent", {
            "indentId": indentId
        });

    }

    function processDrugIndent(indentId) {
        window.location.href = emr.pageLink("inventoryapp", "mainStoreDrugProcessIndent", {
            "indentId": indentId
        });
    }

    var prescriptionDialog = emr.setupConfirmationDialog({
        selector: '#prescription-dialog',
        actions: {
            confirm: function () {
                console.log("This is the prescription object:");
                prescriptionDialog.close();
            },
            cancel: function () {
                prescriptionDialog.close();
            }
        }
    });


    function getIndentList(storeId, statusId, indentName, fromDate, toDate, viewIndent, indentId) {
        jq.getJSON('${ui.actionLink("inventoryapp", "transferDrugFromGeneralStore", "getIndentList")}',
                {
                    storeId: storeId,
                    statusId: statusId,
                    indentName: indentName,
                    fromDate: fromDate,
                    toDate: toDate,
                    viewIndent: viewIndent,
                    indentId: indentId
                }).success(function (data) {
                    if (data.length === 0 && data != null) {
                        jq().toastmessage('showNoticeToast', "No drug found!");
                        jq('#transferList > tbody > tr').remove();
                        var tbody = jq('#transferList > tbody');
                        var row = '<tr align="center"><td colspan="6">No Drugs found</td></tr>';
                        tbody.append(row);
                    } else {
                        updateTransferList(data);
                    }
                }).error(function () {
                    jq().toastmessage('showNoticeToast', "An Error Occured while Fetching List");
                    jq('#transferList > tbody > tr').remove();
                    var tbody = jq('#transferList > tbody');
                    var row = '<tr align="center"><td colspan="6">No Drugs found</td></tr>';
                    tbody.append(row);
                });
    }

    //update the queue table
    function updateTransferList(tests) {
        jq('#transferList > tbody > tr').remove();
        var tbody = jq('#transferList > tbody');

        for (index in tests) {
            var row = '<tr>';
            var item = tests[index];
            row += '<td>' + (++index) + '</td>';
            row += '<td>' + item.store.name + '</td>';
            row += '<td><a href="#" title="Detail indent" onclick="detailDrugIndent(' + item.id + ');" ;>' + item.name + '</a></td>';
            row += '<td>' + item.createdOn + '</td>';
            row += '<td>' + item.mainStoreStatusName + '</td>';
            var link = "";
            if (item.mainStoreStatus == 1) {
                link += '<a href="#" title="Process Indent" onclick="processDrugIndent(' + item.id + ');" >Process Indent</a>';
            }
            row += '<td>' + link + '</td>';
            row += '</tr>';
            tbody.append(row);
        }
    }

</script>

<style>
	fieldset {
		background: #f3f3f3 none repeat scroll 0 0;
		margin: 0 0 5px;
		padding: 5px 0 5px 5px;
	}
	fieldset label{
		color: #f26522;
		display: inline-block;
		margin: 5px 0;
		padding-left: 1%;
		width: 23%;
	}
	fieldset input{
		width: 25%;
	}
	fieldset select{
		width: 24%;
	}
</style>

<div class="dashboard clear">
	<div class="info-section">
		<div class="info-header">
			<i class="icon-book"></i>
			<h3>Manage Indent</h3>
			
			<div>
				<i class="icon-filter" style="font-size: 26px!important; color: #5b57a6"></i>
				
				
				<label for="categoryId">Filter : </label>
				
				<input type="text" id="indentName" name="indentName" placeholder="Filter by Indent Name" title="Enter Indent Name" style="width: 492px; padding-left: 30px;"/>
				<i class="icon-search" style="color: #aaa; float: right; position: absolute; font-size: 16px ! important; margin-left: -490px; margin-top: 4px;"></i>
				
				<a class="button task" id="expirySearch">
					Search
				</a>
			</div>
		</div>
	</div>
</div>

<fieldset id="filters">
	<label for="storeId" >Requesting Store</label>
	<label for="statusId">Indent Status</label>
	<label for="fromDate">From Date</label>
	<label for="toDate" style="width: auto; padding-left: 17px;">To Date</label>
	
	<br/>

	<select name="storeId" id="storeId" class="searchFieldChange" title="Select Drug Store">
		<option value="">Select Store</option>
		<% listStore.each { %>
			<option value="${it.id}" title="${it.name}">${it.name}</option>
		<% } %>
	</select>

    <select name="statusId" id="statusId" class="searchFieldChange" title="Select Status">
        <option value="">Select Status</option>
        <% listMainStoreStatus.each { %>
			<option value="${it.id}" title="${it.name}">${it.name}</option>
        <% } %>
    </select>
		   
    <input type="text" id="fromDate" class="date-pick searchFieldChange searchFieldBlur" readonly="readonly" name="fromDate"
           title="Double Click to Clear" ondblclick="this.value = '';"/>
		   
    <input type="text" id="toDate" class="date-pick searchFieldChange searchFieldBlur" readonly="readonly" name="toDate"
           title="Double Click to Clear" ondblclick="this.value = '';"/>

</fieldset>

<table id="transferList">
   
    <thead>
    <th>#</th>
    <th>From Store</th>
    <th>Indent Name</th>
    <th>Created On</th>
    <th>Status Indent</th>
    <th>Action</th>
    </thead>
    <tbody role="alert" aria-live="polite" aria-relevant="all">
    <tr align="center">
        <td colspan="6">No Indent found</td>
    </tr>
    </tbody>
</table>