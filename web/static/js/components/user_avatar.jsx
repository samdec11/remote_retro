import React from "react"
import SimpleWebRTC from "simplewebrtc"
import * as AppPropTypes from "../prop_types"
import styles from "./css_modules/user_list_item.css"

class UserAvatar extends React.Component {
  constructor(props) {
    super(props)
    this.webrtc = new SimpleWebRTC({
      localVideoEl: "video",
      remoteVideosEl: "",
      autoRequestMedia: true,
      nick: this.props.givenName,
    })
    this.state = {
      videoEnabled: false,
    }
  }

  componentDidMount() {
    this.webrtc.on("readyToCall", () => {
      this.webrtc.joinRoom("the room where it happens")
      this.setState({ videoEnabled: true })
    })
  }

  render() {
    const { user, givenName } = this.props
    const imgSrc = user.picture.replace("sz=50", "sz=200")

    if (this.state.videoEnabled) {
      return (
        <video id="video" className={styles.video} />
      )
    }
    return (
      <img className={styles.picture} src={imgSrc} alt={givenName} />
    )
  }
}

UserAvatar.propTypes = {
  user: AppPropTypes.user.isRequired,
  givenName: React.PropTypes.string.isRequired,
}

export default UserAvatar
