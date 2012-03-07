// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require_tree .
var search_text = ""
var search_type = ""
var is_content_search = ""
var categories_list = []
var books_list = []
var search_list = []
var autocomplete_list = []

function generateAutocompleteList() {
  autocomplete_list = [];
  $.each(books_list, function(k, v, el) {
    if (v != null && typeof v === "object"){
      $.each(v.books, function(k_b, v_b, el_b) {
        autocomplete_list.push(v_b.author);
        autocomplete_list.push(v_b.name);
      });
    }
  });
  autocomplete_list = _.uniq(autocomplete_list);
}

function getBookSearchPages(id) {
  var result = []; 
  $.each(search_list, function(k, v, el) {
    if (v != null && typeof v === "object"){
      if (v.obj.id == id) {
        result = v.pages;
      }
    }
  });
  return result;
}

function updateCategories() {
  $.ajax({
    url: '/categories/get_list',
    success: function( data ) {
      categories_list = data;
      renderCategories();
    }
  });
}

function updateBooks() {
  $.ajax({
    url: '/books/get_list',
    data: 'category=0',
    success: function( data ) {
      books_list = data;
      renderBooks();
      generateAutocompleteList();
      $('.search_field').autocomplete({
        source: autocomplete_list,
        minLength: 3
      });
    }
  });
}

function renderCategories() {
  resetUi();
  $('.category_select').append(ich.option_category({id: '0', name: ''}));
  $.each(categories_list, function(k, v, el) {
    if (v != null && typeof v === "object"){
      $('.categories_list').append(ich.category({id: v.id, name: v.name}));
      $('.category_select').append(ich.option_category({id: v.id, name: v.name}));
      $('.book_category_select').append(ich.option_category({id: v.id, name: v.name}));
    }
  });
  renderBookcatalog();
  $('#bookcatalog').treeview();
  $('#bookcatalog_test').treeview();
}
//need make insertAfter unical id
function renderBooks() {
  console.log("renderBooks>>>>>>>>>>>>>>>>>>>>>>>>>>>");
  $.each(books_list, function(k, v, el) {
    //console.log(v.cat_name);
    if (v != null && typeof v === "object"){
      $('.books_list').append(ich.category({id: v.cat_id, name: v.cat_name}));
      $.each(v.books, function(k_b, v_b, el_b) {
        if (v_b != null && typeof v_b === "object"){
          $('.books_list').append(ich.book({
            book_id: v_b.id ,
            author: v_b.author,
            name: v_b.name,
            description: v_b.description,
            filename: v_b.filename
          }));
          $('#folder-' + v.cat_id).append(ich.tree_book({
            book_id: v_b.id ,
            author: v_b.author,
            name: v_b.name,
            description: v_b.description,
            filename: v_b.filename
          }));
        }
      });
    }
  });
  $('.read_book').bind('click', function(event) {
    event.preventDefault();
    addBookTab(event.currentTarget.id, 'default');
  });
  $('.file').bind('click', function(event) {
    event.preventDefault();
    addBookTab(event.currentTarget.id, 'default');
  });
}

function renderSearch() {
  $( '.usertabs' ).tabs( 'select', '#usertab-search');
  $('.search_list').empty();
  $('.search_list').append("<div id='search_list'></div>");
  console.log(">>>>>>>>>>>>>>>>>>>>>>>>> renderSearch");
  $.each(search_list, function(k_b, v_b, el_b) {
    if (v_b != null && typeof v_b.obj === "object"){
      $('#search_list').append(ich.headbook({
        book_id: v_b.obj.id ,
        author: v_b.obj.author,
        name: v_b.obj.name,
        description: v_b.obj.description,
        filename: v_b.obj.filename
        //pages: JSON.stringify(v_b.pages)
      }));
      $.each(v_b.pages, function(k_p, v_p, el_p) {
        console.log(v_b.obj.id);
        console.log(v_p);
      	if (v_p != null){
          $('#read_book_search_pages-' + v_b.obj.id + ' p').append(ich.search_page({
            book_id: v_b.obj.id ,
            page: v_p
            //pages: JSON.stringify(v_b.pages)
          }));
        }
      });
      //
      //
      //
      //
      //
      //
      //
      //
      //
      //.go_search_page
      //$('.read_book_search').bind('click', function(event) {
	  	//var id = event.currentTarget.id;
	    //event.preventDefault();
	    //addBookTab(id, 'search');
        if (search_type == 'by_content'){
          console.log(">>>>>>>>>>>>>>>>>>>>>>>>> show page");
	      $('#headbook_content_search-' + v_b.obj.id).show();
	    } else {
	      console.log(">>>>>>>>>>>>>>>>>>>>>>>>> hide page");
          $('.headbook_content_search').hide();
        }
      //});
    }
  });
  $('#search_list').accordion();
  $('.read_book_search').bind('click', function(event) {
  	var id = event.currentTarget.id;
    event.preventDefault();
    addBookTab(id, 'search');
    if (search_type == 'by_content'){
      console.log(">>>>>>>>>>>>>>>>>>>>>>>>> show search");
      $('#read_book_content_search-' + id).show();
    } else {
      console.log(">>>>>>>>>>>>>>>>>>>>>>>>> hide search");
      $('.read_book_content_search').hide();
    }
  })
  //$( '#search_list' ).accordion({
  // change: function(event, ui) {
  // 	 event.preventDefault();
  // 	 console.log(ui.newHeader[0].childNodes[2].id);
  //   loadBook(ui.newHeader[0].childNodes[2].id);
  // }
  //});
}

function resetUi() {
  $('.categories_list').empty();
  $('.category_select').empty();
  $('.category_field').val('');
  $('.books_list').empty();
  //$('.search_list').empty();
  //$('.category_select').val('0');
}

//best way to output pages
function addBookTab(book_id, type) {
  $.ajax({
    url: '/books/get_book_info',
    data: 'book_id=' + book_id,
    type: 'get',
    success: function( data ) {
      var slider_class = '.slider-' + book_id;
      if ($('#usertab-book-' + book_id).length == 0)
      {
        $( '.usertabs' ).tabs( 'add', '#usertab-book-' + book_id, data.author + ' - ' + data.name );
        $('#usertab-book-' + book_id).append(ich.read_book({id: book_id}));
        $(slider_class).slider();
        $(slider_class).slider({ animate: true });
        $(slider_class).slider({ value: 1 })
        $(slider_class).slider({ step: 1 });
        $(slider_class).slider({ min: 1 });
        $(slider_class).slider({ max: data.pages });
        $(slider_class).bind('slide', function(event, ui) {
          $('.page_counter-' + book_id).html($(slider_class).slider('value'));
        });
        $('.page_total-' + book_id).html(data.pages);
        var book_search_pages = getBookSearchPages(book_id);
        book_search_length = book_search_pages.length;
        $('.content_total-' + book_id).html(book_search_length);
        $(slider_class).bind('slidechange', function(event, ui) {
          var page = $(slider_class).slider('value');
          renderPage(book_id, page);
        });
        $('.page_button_left-' + book_id).bind('click', function(event, ui) {
          var book = event.currentTarget.id;
          var page = $('.slider-' + book).slider('value');
          if (page > $('.slider-' + book).slider('option', 'min')){
            $('.slider-' + book).slider('value', page - 1);
            $('.page_counter-' + book).html($('.slider-' + book).slider('value')); 
          }
        });
        $('.page_button_right-' + book_id).bind('click', function(event, ui) {
          var book = event.currentTarget.id;
          var page = $('.slider-' + book).slider('value');
          if (page < $('.slider-' + book).slider('option', 'max')){
            $('.slider-' + book).slider('value', page + 1);
            $('.page_counter-' + book).html($('.slider-' + book).slider('value')); 
          }
        });
        $('.content_button_right-' + book_id).bind('click', function(event, ui) {
          var book_id = event.currentTarget.id;
          var num_search = parseInt($('.content_counter-' + book_id).html()); 
          
          if (num_search < parseInt($('.content_total-' + book_id).html())){
          	num_search = num_search + 1;
            $('.slider-' + book_id).slider('value', book_search_pages[num_search - 1]);
            $('.content_counter-' + book_id).html(num_search); 
          }
          console.log(render_page);
        });
        $('.content_button_left-' + book_id).bind('click', function(event, ui) {
          var book_id = event.currentTarget.id;
          var num_search = parseInt($('.content_counter-' + book_id).html());
          
          if (num_search > 1){
          	num_search = num_search - 1;
            $('.slider-' + book_id).slider('value', book_search_pages[num_search - 1]);
            $('.content_counter-' + book_id).html(num_search); 
          }
        });
        var render_page = 1;
        if (type = 'search'){
          if (book_search_length > 0){
            var num_search = parseInt($('.content_counter-' + book_id).html());
            render_page = book_search_pages[num_search - 1];
          }
        }
        renderPage(book_id, render_page);
      }
      $( '.usertabs' ).tabs( 'select', '#usertab-book-' + book_id);
    }
  });
}

//output book pages in accordion (need to test) 
function loadBook(book_id) {
  $.ajax({
    url: '/books/get_book_info',
    data: 'book_id=' + book_id,
    type: 'get',
    success: function( data ) {
      var slider_class = '.slider-' + book_id;
      $(slider_class).slider();
      $(slider_class).slider({ animate: true });
      $(slider_class).slider({ value: 1 })
      $(slider_class).slider({ step: 1 });
      $(slider_class).slider({ min: 1 });
      $(slider_class).slider({ max: data.pages });
      $(slider_class).bind('slide', function(event, ui) {
        $('.page_counter-' + book_id).html($(slider_class).slider('value'));
      });
      $(slider_class).bind('slidechange', function(event, ui) {
        var page = $(slider_class).slider('value');
        renderPage(book_id, page);
      });
      $('.page_button_left-' + book_id).bind('click', function(event, ui) {
        var book = event.currentTarget.id;
        var page = $('.slider-' + book).slider('value');
        if (page > $('.slider-' + book).slider('option', 'min')){
          $('.slider-' + book).slider('value', page - 1);
          $('.page_counter-' + book).html($('.slider-' + book).slider('value')); 
        }
      });
      $('.page_button_right-' + book_id).bind('click', function(event, ui) {
        var book = event.currentTarget.id;
        var page = $('.slider-' + book).slider('value');
        if (page < $('.slider-' + book).slider('option', 'max')){
          $('.slider-' + book).slider('value', page + 1);
          $('.page_counter-' + book).html($('.slider-' + book).slider('value')); 
        }
      });
    }
  });
}

function renderPage(book_id, page) {
  $('.page_counter-' + book_id).html(page);
  $.ajax({
    url: '/books/get_page',
    data: 'book_id=' + book_id + '&page_num=' + page,
    success: function( data ) {
      //var hoptions = { wordsOnly: true };
      //el.highlight(phrase.replace(/^"|"$/g, ''), hoptions);
      $('#page-' + book_id).html(data);
      if (search_type == "by_content"){
        var highlighted_text = search_text.replace(/\=/, "");
        if (search_text.length > 7){
          var highlighted_text_extend_form = highlighted_text.slice(0, search_text.length - 2);
          $('.page').highlight(highlighted_text_extend_form, { wordsOnly: true });
        }
        $('.page').highlight(highlighted_text, { wordsOnly: true });
      }
    }
  });
}

function renderBookcatalog() {
  console.log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>> renderBookcatalog()");
  $('#bookcatalog').append(ich.sub_category({id: '0', sub_cat: 'Библиотека'}));
  $.each(categories_list, function(k, v, el) {
    if (v != null && typeof v === "object"){
      $('#folder-' + v.parent_id).append(ich.sub_category({id: v.id, sub_cat: v.origin_name}));
    }
  });
}

$(document).ready(function() {
  resetUi();
  updateCategories();
  updateBooks();
  $('.usertabs').tabs();
  $('#browser').treeview();

  $('input.add_category_button').bind('click', function() {
    //todo: add regexp-validation of name
    if ($('.category_field').val() != ''){
      $.ajax({
        url: '/categories/add',
        data: 'name=' + $('.category_field').val() + '&parent_id=' + $('.category_select').val(),
        type: 'post',
        success: function( data ) {
          updateCategories();
        }
      });
    }
    else{
      alert("Field cannot be empty!");
    }
  })
  
  $('input.search_button').bind('click', function() {
    search_text = $('.search_field').val();
    search_type = $('input[name=search_radio]:radio:checked').val();
    if (search_text != ''){
      if (search_type == 'by_name'){
	    $.ajax({
	      url: '/books/search_by_name',
	      data: 'search=' + search_text,
	      type: 'get',
	      success: function( data ) {
	        search_list = data;
	        renderSearch();
	      }
	    });
	  } else { //search by content
	  	$.ajax({
	      url: '/books/search_by_content',
	      data: 'search=' + search_text,
	      type: 'get',
	      success: function( data ) {
	        search_list = data;
	        renderSearch();
	      }
	    });
	  }
    }
    else{
      alert("Field cannot be empty!");
    }
  })
});