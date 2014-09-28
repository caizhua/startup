import 'package:polymer/polymer.dart';
export 'package:polymer/init.dart';

@CustomTag('x-dialog')
class XDialog extends PolymerElement {
  @observable bool opened = false;
  @observable bool autoCloseDisabled = true;

  XDialog.created() : super.created();
  ready() {
    $['overlay'].target = this;
  }

  toggle() {
    $['overlay'].toggle();
  }
}