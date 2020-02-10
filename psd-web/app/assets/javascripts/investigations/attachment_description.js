import $ from 'jquery';

$(document).ready(() => {
  const attachmentFileInput = $('input.govuk-file-upload');
  const attachmentDescription = document.getElementById('attachment-description');
  const currentAttachmentDetails = document.getElementById('current-attachment-details');

  attachmentFileInput.change(function() {
    if (this.value) {
      $(attachmentDescription).show();
    } else {
      $(attachmentDescription).hide();
    }
  });

  if (attachmentDescription) {
    if (currentAttachmentDetails) {
      $(attachmentDescription).show();
    } else {
      $(attachmentDescription).hide();
    }
  }
});
