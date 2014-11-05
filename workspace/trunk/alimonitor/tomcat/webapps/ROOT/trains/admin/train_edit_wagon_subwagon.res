subwagon name 
<<:com_edit_start:>>
<input type=text size=20 name="subwagon_<<:list_id:>>_name" id="subwagon_<<:list_id:>>_name" value="<<:subwagon_name:>>" class=input_text>
<<:com_edit_end:>>
<<:!com_edit_start:>>
<<:subwagon_name:>>
<<:!com_edit_end:>>
<input type="checkbox" name="subwagon_<<:list_id:>>_checkbox" id="subwagon_<<:list_id:>>_checkbox" value="1" <<:com_activated_start:>>checked <<:com_activated_end:>> <<:!com_edit_start:>>disabled<<:!com_edit_end:>>>  <<:com_activated_start:>>activated<<:com_activated_end:>> <br>
<textarea rows=3 cols=98 class=input_textarea name="subwagon_<<:list_id:>>" id="subwagon_<<:list_id:>>" <<:!com_edit_start:>>disabled<<:!com_edit_end:>>> <<:config:>> </textarea> 
<<:com_edit_start:>>
<input type=submit name=submit value="remove subwagon" class=input_submit onClick="return remove_subwagon('<<:list_id:>>');"> <br>
<<:com_edit_end:>>
<br> <br>
