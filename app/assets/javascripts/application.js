// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require sivel2_gen/application
//= require heb412_gen/motor
//= require_tree .

$(document).on('turbolinks:load ready page:load', function() {
	var root;
  	root = typeof exports !== "undefined" && exports !== null ? 
	  exports : window;
	sip_prepara_eventos_comunes(root);
	heb412_gen_prepara_eventos_comunes(root);
	sivel2_gen_prepara_eventos_comunes(root);
	sivel2sd_prepara_eventos_unicos(root);
      
	//root.formato_fecha = 'dd/M/yyyy'
	//if ($('meta[name=formato_fecha]').size() != 0 &&
        //  $('meta[name=formato_fecha]').attr('content').length > 0) {
//		root.formato_fecha = $('meta[name=formato_fecha]').attr('content')
//	}
	$('[data-behaviour~=datepicker]').datepicker({
		format: root.formato_fecha,
		autoclose: true,
		todayHighlight: true,
		language: 'es'	
	});
	$('.chosen-select').chosen({
		allow_single_deselect: true,
		no_results_text: 'No hay opciones',
		placeholder_text_multiple: 'Elija una o más opciones',
		placeholder_text_single: 'Elija una opción',
		width: '200px'
	});

});


