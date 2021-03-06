module CorrectiveActionsConcern
  extend ActiveSupport::Concern

  def set_investigation
    investigation = Investigation.find_by!(pretty_id: params[:investigation_pretty_id])
    authorize investigation, :view_non_protected_details?
    @investigation = investigation.decorate
  end

  def set_corrective_action
    corrective_action = @investigation.corrective_actions.build(corrective_action_params)
    corrective_action.set_dates_from_params(params[:corrective_action])
    @corrective_action = corrective_action.decorate
  end

  def corrective_action_params
    corrective_action_session_params.merge(corrective_action_request_params)
  end

  def set_attachment
    @file_blob, * = load_file_attachments
    if @file_blob && @corrective_action.related_file?
      @corrective_action.documents.attach(@file_blob)
    end
  end

  def update_attachment
    update_blob_metadata @file_blob, corrective_action_file_metadata
  end

  def corrective_action_valid?
    @corrective_action.validate(step)
    validate_blob_size(@file_blob, @corrective_action.errors, "file")
    @corrective_action.errors.empty?
  end

  def corrective_action_request_params
    return {} if params[:corrective_action].blank?

    params.require(:corrective_action).permit(
      :product_id,
      :business_id,
      :legislation,
      :action,
      :other_action,
      :details,
      :related_file,
      :measure_type,
      :duration,
      :geographic_scope,
      date_decided: %i[day month year]
    )
  end

  def corrective_action_file_metadata
    get_attachment_metadata_params(:file).merge(
      title: @corrective_action.action,
      other_type: "Corrective action document",
      document_type: :other
    )
  end
end
