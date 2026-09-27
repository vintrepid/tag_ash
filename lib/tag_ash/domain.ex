defmodule TagAsh.Domain do
  @moduledoc "Ash domain for reusable tag contexts, tags, assignments, and hierarchy."

  use Ash.Domain, otp_app: :tag_ash

  resources do
    resource TagAsh.Resources.Context do
      define :contexts, action: :read
      define :upsert_context, action: :upsert
      define :context_by_key, action: :by_key, args: [:owner_ref, :key]
    end

    resource TagAsh.Resources.Tag do
      define :tags, action: :read
      define :tags_for_context, action: :for_context, args: [:context_id]
      define :upsert_tag, action: :upsert
      define :tag_by_slug, action: :by_slug, args: [:context_id, :slug]
    end

    resource TagAsh.Resources.SubjectTag do
      define :subject_tags, action: :for_subject, args: [:subject_ref]
      define :attach_tag, action: :attach
      define :detach_tag, action: :destroy
    end

    resource TagAsh.Resources.TagHierarchy do
      define :tag_hierarchy, action: :read
      define :link_tags, action: :link
      define :unlink_tags, action: :destroy
    end
  end
end
