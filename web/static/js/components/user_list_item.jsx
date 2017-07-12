import React from "react"
import * as AppPropTypes from "../prop_types"
import styles from "./css_modules/user_list_item.css"
import AnimatedEllipsis from "./animated_ellipsis"
import UserAvatar from "./user_avatar"

const UserListItem = ({ user }) => {
  let givenName = user.given_name
  if (user.is_facilitator) givenName += " (Facilitator)"

  return (
    <li className={`item ${styles.wrapper}`}>
      <div className="ui center aligned grid">
        <UserAvatar user={user} givenName={givenName} />
        <div className="ui row">
          <p className={styles.name}>{ givenName }</p>
          <p className={`${styles.animatedEllipsisWrapper} ui row`}>
            { user.is_typing && <AnimatedEllipsis /> }
          </p>
        </div>
      </div>
    </li>
  )
}

UserListItem.propTypes = {
  user: AppPropTypes.user.isRequired,
}

export default UserListItem
