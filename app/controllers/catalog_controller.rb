# frozen_string_literal: true
class CatalogController < ApplicationController
  include BlacklightAdvancedSearch::Controller

  include Blacklight::Catalog
  include Blacklight::Marc::Catalog
  include BlacklightRangeLimit::ControllerOverride

  configure_blacklight do |config|
    config.view.gallery.partials = [:index_header, :index]
    config.view.masonry.partials = [:index]
    config.view.slideshow.partials = [:index]


    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'dismax'
    config.advanced_search[:form_solr_parameters] ||= {}

    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      rows: 20,
      'facet.mincount': 1,
      'q.alt': '*:*',
      'defType': 'dismax',
      'df': 'text',
      'q.op': 'AND'
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    config.default_document_solr_params = {
      qt: 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # fl: '*',
    #  # rows: 1,
      q: '{!term f=id v=$id}'
    }

    # solr field configuration for search results/index views
    config.index.title_field = 'objname_s'
    #config.index.display_type_field = 'format'
    #config.index.thumbnail_field = 'primaryimage_s'
    config.index.thumbnail_field = 'blob_ss'

    # solr field configuration for document/show views
    config.show.title_field = 'objname_s'
    #config.show.display_type_field = 'format'
    #config.show.thumbnail_field = 'primaryimage_s'
    config.show.thumbnail_field = 'blob_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)


    config.add_facet_field 'objtype_s', label: 'Object Type'
    config.add_facet_field 'objdept_s', label: 'Department', limit: true
    config.add_facet_field 'hasimages_s', label: 'Media'
    config.add_facet_field 'objfcp_s', label: 'Collection Place', limit: true
    config.add_facet_field 'objfilecode_ss', label: 'Ethnographic File Code', limit: true
    config.add_facet_field 'objassoccult_ss', label: 'Culture or Time period', limit: true
    config.add_facet_field 'objcollector_ss', label: 'Collector', limit: true
    config.add_facet_field 'objmaterials_ss', label: 'Materials', limit: true
    config.add_facet_field 'objtitle_s', label: 'Title', limit: true
    #config.add_facet_field 'objproddate_begin_dt', label: 'Production Date'
    
    config.add_facet_field "objproddate_begin_dt", :label => "Production Date", :partial => "blacklight_range_limit/range_limit_panel", :range => {
          :input_label_range_begin => "from year",
          :input_label_range_end => "to year"
    }
    
    config.add_facet_field 'objpp_ss', label: 'Production Place', limit: true
    config.add_facet_field 'objmaker_ss', label: 'Maker / Artist', limit: true
    config.add_facet_field 'objname_s', label: 'Object Name', limit: true

    #config.add_facet_field 'example_query_facet_field', label: 'Publish Date', :query => {
    #   :years_5 => { label: 'within 5 Years', fq: "pub_date:[#{Time.zone.now.year - 5 } TO *]" },
    #   :years_10 => { label: 'within 10 Years', fq: "pub_date:[#{Time.zone.now.year - 10 } TO *]" },
    #   :years_25 => { label: 'within 25 Years', fq: "pub_date:[#{Time.zone.now.year - 25 } TO *]" }
    #}


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display

config.add_index_field  'objmusno_s', label: 'Museum Number'
#config.add_index_field  'objname_s', label: 'Object Name'
config.add_index_field  'objtype_s', label: 'Object Type'
config.add_index_field  'objcount_s', label: 'Object Count'
config.add_index_field  'objfcp_s', label: 'Collection Place'
config.add_index_field  'objfcpverbatim_s', label: 'Collection Place (verbatim)'
config.add_index_field  'objfilecode_ss', label: 'Ethnographic File Code'
config.add_index_field  'objassoccult_ss', label: 'Culture or Time period'
config.add_index_field  'objcollector_ss', label: 'Collector'
config.add_index_field  'objcolldate_s', label: 'Collection Date'
config.add_index_field  'objproddate_s', label: 'Production Date'
config.add_index_field  'objpp_ss', label: 'Production Place'
config.add_index_field  'objmaker_ss', label: 'Maker / Artist'
    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display

config.add_show_field  'objmusno_s', label: 'Museum Number'
#config.add_show_field  'objname_s', label: 'Object Name'
config.add_show_field  'objaltnum_ss', label: 'Alternate Number'
config.add_show_field  'objtype_s', label: 'Object Type'
config.add_show_field  'objcount_s', label: 'Object Count'
config.add_show_field  'objcountnote_s', label: 'Count Note'
config.add_show_field  'objdept_s', label: 'Department'
config.add_show_field  'objkeelingser_s', label: 'Keeling Series Number'
config.add_show_field  'objfcp_s', label: 'Collection Place'
config.add_show_field  'objfcpverbatim_s', label: 'Collection Place (verbatim)'
config.add_show_field  'objfilecode_ss', label: 'Ethnographic File Code'
config.add_show_field  'objassoccult_ss', label: 'Culture or Time period'
config.add_show_field  'objinventory_s', label: 'Inventory'
config.add_show_field  'objcollector_ss', label: 'Collector'
config.add_show_field  'objdescr_s', label: 'Description'
config.add_show_field  'objcontextuse_s', label: 'Context of Use'
config.add_show_field  'objdimensions_ss', label: 'Dimensions'
config.add_show_field  'objmaterials_ss', label: 'Materials'
config.add_show_field  'objinscrtext_ss', label: 'Inscription'
config.add_show_field  'objcomment_s', label: 'Comment'
config.add_show_field  'objtitle_s', label: 'Title'
config.add_show_field  'objcolldate_s', label: 'Collection Date'
config.add_show_field  'objproddate_s', label: 'Production Date'
config.add_show_field  'objaccno_ss', label: 'Accession Number'
config.add_show_field  'objaccdate_ss', label: 'Accession Date'
config.add_show_field  'objacqdate_ss', label: 'Acquisition Date'
config.add_show_field  'objfcpgeoloc_p', label: 'LatLong'
config.add_show_field  'objfcpelevation_s', label: 'Collection Place Elevation'
config.add_show_field  'imagetype_ss', label: 'Image Type'
config.add_show_field  'hasimages_s', label: 'Has image(s)?'
config.add_show_field  'hascoords_s', label: 'Has coordinates?'
config.add_show_field  'anonymousdonor_ss', label: 'Donor'
config.add_show_field  'objpp_ss', label: 'Production Place'
config.add_show_field  'objmaker_ss', label: 'Maker / Artist'
    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'text', label: 'All Fields'
    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

#       config.add_search_field('text') do |field|
#         # solr_parameters hash are sent to Solr as ordinary url query params.
#         field.solr_parameters = { :'spellcheck.dictionary' => 'text' }
#   
#         # :solr_local_parameters will be sent using Solr LocalParams
#         # syntax, as eg {! qf=$title_qf }. This is neccesary to use
#         # Solr parameter de-referencing like $title_qf.
#         # See: http://wiki.apache.org/solr/LocalParams
#         field.solr_local_parameters = {
#           qf: '$text_qf',
#           pf: '$text_pf'
#         }
#       end
   #
   #    config.add_search_field('author') do |field|
   #      field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
   #      field.solr_local_parameters = {
   #        qf: '$author_qf',
   #        pf: '$author_pf'
   #      }
   #    end
   #
   #    # Specifying a :qt only to show it's possible, and so our internal automated
   #    # tests can test it. In this case it's the same as
   #    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
   #    config.add_search_field('subject') do |field|
   #      field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
   #      field.qt = 'search'
   #      field.solr_local_parameters = {
   #        qf: '$subject_qf',
   #        pf: '$subject_pf'
   #   }
   # end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'objsortnum_s asc', label: 'museum number'
    config.add_sort_field 'objname_s asc, objsortnum_s asc', label: 'object name'
    #config.add_sort_field 'pub_date_sort desc, title_sort asc', label: 'year'
    #config.add_sort_field 'author_sort asc, title_sort asc', label: 'author'
    #config.add_sort_field 'title_sort asc, pub_date_sort desc', label: 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
  end
end
