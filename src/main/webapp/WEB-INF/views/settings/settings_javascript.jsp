<%@taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<script type="text/javascript" charset="utf-8">
   function CropAvatar($element) {
      this.$container = $element;

      this.$avatarView = this.$container.find('.avatar-view');
      this.$allAvatar = $('.avatar_image');
      this.$avatar = this.$avatarView.find('img');
      this.$avatarTooltip = this.$avatarView.find('#avatarTooltip');
      this.$avatarModal = this.$container.find('#avatar-modal');
      this.$avatarForm = this.$avatarModal.find('.avatar-form');
      this.$avatarUpload = this.$avatarForm.find('.avatar-upload');
      this.$avatarSrc = this.$avatarForm.find('.avatar-src');
      this.$avatarData = this.$avatarForm.find('.avatar-data');
      this.$avatarInput = this.$avatarForm.find('.avatar-input');
      this.$avatarSave = this.$avatarForm.find('.avatar-save');
      this.$avatarBtns = this.$avatarForm.find('.avatar-btns');

      this.$avatarWrapper = this.$avatarModal.find('.avatar-wrapper');
      this.$avatarPreview = this.$avatarModal.find('.avatar-preview');

      this.init();
   }

   $(document)
         .ready(
               function() {
                  CropAvatar.prototype = {
                     constructor : CropAvatar,

                     support : {
                        fileList : !!$('<input type="file">').prop('files'),
                        blobURLs : !!window.URL && URL.createObjectURL,
                        formData : !!window.FormData
                     },

                     init : function() {
                        this.support.datauri = this.support.fileList
                              && this.support.blobURLs;

                        if (!this.support.formData) {
                           this.initIframe();
                        }

                        this.initModal();
                        this.addListener();
                     },

                     addListener : function() {
                        this.$avatarTooltip.on('click', $.proxy(this.click,
                              this));
                        this.$avatarInput.on('change', $.proxy(this.change,
                              this));
                        this.$avatarForm.on('submit', $
                              .proxy(this.submit, this));
                        this.$avatarBtns.on('click', '[data-method]', $.proxy(
                              this.methods, this));
                     },

                     initModal : function() {
                        this.$avatarModal.modal({
                           show : false
                        });
                        var _this = this;
                        this.$avatarModal.on('shown.bs.modal', function() {
                           _this.$avatarSave.prop("disabled", true);
                        })
                     },

                     initPreview : function() {
                        var url = this.$avatar.attr('src');

                        this.$avatarPreview.html('<img src="' + url + '">');
                     },

                     initIframe : function() {
                        var target = 'upload-iframe-' + (new Date()).getTime();
                        var $iframe = $('<iframe>').attr({
                           name : target,
                           src : ''
                        });
                        var _this = this;

                        // Ready ifrmae
                        $iframe.one('load', function() {

                           // respond response
                           $iframe.on('load', function() {
                              var data;

                              try {
                                 data = $(this).contents().find('body').text();
                              } catch (e) {
                                 console.log(e.message);
                              }

                              if (data) {
                                 try {
                                    data = $.parseJSON(data);
                                 } catch (e) {
                                    console.log(e.message);
                                 }

                                 _this.submitDone(data);
                              } else {
                                 _this.submitFail('Image upload failed!');
                              }

                              _this.submitEnd();

                           });
                        });

                        this.$iframe = $iframe;
                        this.$avatarForm.attr('target', target).after(
                              $iframe.hide());
                     },

                     click : function() {
                        this.$avatarModal.modal('show');
                        this.initPreview();
                     },

                     change : function() {
                        var files;
                        var file;

                        if (this.support.datauri) {
                           files = this.$avatarInput.prop('files');

                           if (files.length > 0) {
                              file = files[0];

                              if (this.isImageFile(file)) {
                                 if (this.url) {
                                    URL.revokeObjectURL(this.url); // Revoke the old
                                    // one
                                 }

                                 this.url = URL.createObjectURL(file);
                                 this.startCropper();
                                 this.enableSaveBtn();
                              } else {
                                 showMessage(
                                             'error',
                                             "<spring:message code='common.error' />",
                                             "<spring:message code='settings.avatar.select.error.message' />");
                                 this.disableSaveBtn();
                              }
                           }
                        } else {
                           file = this.$avatarInput.val();

                           if (this.isImageFile(file)) {
                              this.syncUpload();
                              this.enableSaveBtn();
                           } else {
                              showMessage(
                                          'error',
                                          "<spring:message code='common.error' />",
                                          "<spring:message code='settings.avatar.select.error.message' />");
                              this.disableSaveBtn();
                           }
                        }
                     },

                     submit : function() {
                        if (!this.$avatarSrc.val() && !this.$avatarInput.val()) {
                           return false;
                        }

                        if (this.support.formData) {
                           this.ajaxUpload();
                           return false;
                        }
                     },

                     methods : function(e) {
                        var data;

                        if (this.active) {
                           data = $(e.target).data();

                           if (data.method) {
                              this.$img.cropper(data.method, data.option,
                                    data.secondOption);
                           }

                           // change the data value in case of scaleX and scaleY
                           switch (data.method) {
                           case 'scaleX':
                           case 'scaleY':
                              $(e.target).data('option', -data.option);
                              break;
                           }
                        }
                     },

                     isImageFile : function(file) {
                        if (file.type) {
                           return /^image\/\w+$/.test(file.type);
                        } else {
                           return /\.(jpg|jpeg|png|gif)$/.test(file);
                        }
                     },

                     startCropper : function() {
                        var _this = this;

                        if (this.active) {
                           this.$img.cropper('replace', this.url);
                        } else {
                           this.$img = $('<img src="' + this.url + '">');
                           this.$avatarWrapper.empty().html(this.$img);
                           this.$img.cropper({
                              aspectRatio : 1,
                              viewMode : 1,
                              dragMode : 'move',
                              autoCropArea : 0.65,
                              restore : true,
                              guides : true,
                              highlight : true,
                              cropBoxMovable : true,
                              cropBoxResizable : false,
                              preview : this.$avatarPreview.selector,
                              crop : function(e) {
                                 var json = [ '{"x":' + e.x, '"y":' + e.y,
                                       '"height":' + e.height,
                                       '"width":' + e.width,
                                       '"scaleX":' + e.scaleX,
                                       '"scaleY":' + e.scaleY,
                                       '"rotate":' + e.rotate + '}' ].join();
                                 _this.$avatarData.val(json);
                              }
                           });

                           this.active = true;
                        }

                        this.$avatarModal.one('hidden.bs.modal', function() {
                           _this.$avatarPreview.empty();
                           _this.stopCropper();
                        });
                     },

                     stopCropper : function() {
                        if (this.active) {
                           this.$avatarForm.trigger("reset");
                           this.$img.cropper('destroy');
                           this.$img.remove();
                           this.active = false;
                        }
                     },

                     ajaxUpload : function() {
                        var url = this.$avatarForm.attr('action');
                        var data = new FormData(this.$avatarForm[0]);
                        data.append('avatar_data', new Blob([ this.$avatarData
                              .val()
                              || null ], {
                           type : "application/json"
                        }));

                        var _this = this;

                        $.ajax(url, {
                           type : 'POST',
                           data : data,
                           dataType : 'json',
                           processData : false,
                           contentType : false,

                           beforeSend : function() {
                              _this.submitStart();
                           },

                           success : function(data) {
                              _this.submitDone(data);
                           },

                           error : function(XMLHttpRequest, textStatus,
                                 errorThrown) {
                              _this.submitFail(textStatus || errorThrown);
                           },

                           complete : function() {
                              _this.submitEnd();
                           }
                        });
                     },

                     syncUpload : function() {
                        this.$avatarSave.click();
                     },

                     submitStart : function() {

                     },

                     submitDone : function(data) {
                        if ($.isPlainObject(data) && data.state === 'SUCCESS') {
                           showMessage(
                                       'success',
                                       "<spring:message code='common.success' />",
                                       "<spring:message code='settings.avatar.upload.success.message' />");
                           this.cropDone();
                        } else {
                           this.submitFail(data.error);
                        }

                     },

                     submitFail : function(errorMessage) {
                        showMessage('error',
                                    "<spring:message code='common.error' />",
                                    "<spring:message code='settings.avatar.upload.error.message' />");
                        this.url = '';
                        this.stopCropper();
                        this.startCropper();
                     },

                     submitEnd : function() {
                     },

                     cropDone : function() {
                        this.$avatarForm.get(0).reset();
                        this.stopCropper();
                        this.$allAvatar.each(function(i, obj) {
                           $(obj).attr(
                                 'src',
                                 $(obj).attr('data_origin_src') + '?'
                                       + (new Date()).getTime());
                        });
                        this.$avatarModal.modal('hide');
                     },

                     enableSaveBtn : function() {
                        this.$avatarSave.prop("disabled", false);
                     },
                     disableSaveBtn : function() {
                        this.$avatarSave.prop("disabled", true);
                     },
                  };

                  // initialize CropAvatar
                  $(function() {
                     return new CropAvatar($('#crop-avatar'));
                  });
                  
                  if(${not empty param.success and param.success}) {
                     showMessage("success", "<spring:message code='common.success' />", "<spring:message code='common.success.message' />");
              	  }
                  
               });
</script>