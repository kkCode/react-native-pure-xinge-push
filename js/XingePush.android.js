
import { DeviceEventEmitter, NativeModules } from 'react-native'

const { RNTXingePush } = NativeModules

export default {

  /**
   * 设置是否开启调试模式，底层 SDK 会打印详细信息
   *
   * @param {boolean} enable
   */
  setDebug(enable) {
    RNTXingePush.setDebug(enable)
  },

  /**
   * 设置是否开启第三方推送通道
   *
   * @param {boolean} enable
   */
  enableOtherPush(enable) {
    RNTXingePush.enableOtherPush(enable)
  },

  /**
   * 设置是否开启华为推送的调试模式
   *
   * @param {boolean} enable
   */
  setHuaweiDebug(enable) {
    RNTXingePush.setHuaweiDebug(enable)
  },

  /**
   * 启动信鸽推送服务，如果是通过点击推送打开的 App，调用 start 后会触发 notification 事件
   *
   * @param {number} accessId
   * @param {string} accessKey
   */
  start(accessId, accessKey) {
    if (typeof accessId !== 'number') {
      console.error(`[XingePush start] accessId is not a number.`)
    }
    if (typeof accessKey !== 'string') {
      console.error(`[XingePush start] accessKey is not a string.`)
    }
    RNTXingePush.start(accessId, accessKey)
  },

  /**
   * 停止信鸽推送服务
   */
  stop() {
    RNTXingePush.stop()
  },

  /**
   * 绑定帐号
   *
   * @param {string} account
   */
  bindAccount(account) {
    RNTXingePush.bindAccount(account)
  },

  /**
   * 解绑帐号
   *
   * @param {string} account
   */
  unbindAccount(account) {
    RNTXingePush.unbindAccount(account)
  },

  /**
   * 绑定标签
   *
   * @param {string} tag
   */
  bindTag(tag) {
    RNTXingePush.bindTag(tag)
  },

  /**
   * 解绑标签
   *
   * @param {string} tag
   */
  unbindTag(tag) {
    RNTXingePush.unbindTag(tag)
  },

  /**
   * 获取当前角标数字
   *
   * @return {Promise} 返回 { badge: 0 }
   */
  getBadge() {
    return RNTXingePush.getBadge()
  },

  /**
   * 设置当前角标数字
   *
   * @param {number} badge
   */
  setBadge(badge) {
    RNTXingePush.setBadge(badge)
  },

  addListener(name, listener) {
    return DeviceEventEmitter.addListener(name, listener)
  }

}