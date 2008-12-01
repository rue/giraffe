<script type="text/javascript">
  $(document).ready(function() {
    $(".edit_area").editable('/eip/<%= @page.name %>', {
      indicator: "saving...",
      tooltip: 'double-click to edit...',
      cancel: 'cancel',
      submit: 'save',
      event: 'dblclick',
      cssclass: 'edit',
      loadurl: '/<%= @page.name %>.txt',
      type: 'textarea',
      name: 'body'
    });
  });
</script>
