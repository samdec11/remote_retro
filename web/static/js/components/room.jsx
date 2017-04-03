import React, { Component } from "react"

import UserList from "./user_list"
import CategoryColumn from "./category_column"
import IdeaSubmissionForm from "./idea_submission_form"
import StageProgressionButton from "./stage_progression_button"
import SendActionItemsEmail from "./send_action_items_email"
import DoorChime from "./door_chime"
import * as AppPropTypes from "../prop_types"

import styles from "./css_modules/room.css"

class Room extends Component {
  constructor(props) {
    super(props)
    this.state = { ideas: [], showActionItem: false }
    this.handleIdeaSubmission = this.handleIdeaSubmission.bind(this)
    this.handleStageProgression = this.handleStageProgression.bind(this)
  }

  componentDidMount() {
    this.props.retroChannel.on("existing_ideas", (payload) => {
      this.setState({ ideas: payload.ideas })
    })

    this.props.retroChannel.on("new_idea_received", (newIdea) => {
      this.setState({ ideas: [...this.state.ideas, newIdea] })
    })

    this.props.retroChannel.on("set_show_action_item", (eventPayload) => {
      this.setState({ showActionItem: eventPayload.show_action_item })
    })
  }

  handleIdeaSubmission(idea) {
    this.props.retroChannel.push("new_idea", idea)
  }

  handleStageProgression() {
    this.props.retroChannel.push("show_action_item", { show_action_item: true })
  }

  render() {
    const retroHasYetToProgressToActionItems = !this.state.showActionItem
    const { currentPresence, users } = this.props
    const { ideas, showActionItem } = this.state
    return (
      <section className={styles.wrapper}>
        <div className={`ui equal width padded grid ${styles.categoryColumnsWrapper}`}>
          <CategoryColumn category="happy" ideas={ideas} />
          <CategoryColumn category="sad" ideas={ideas} />
          <CategoryColumn category="confused" ideas={ideas} />
          { showActionItem ? <CategoryColumn category="action-item" ideas={ideas} /> : null }
        </div>

        <UserList users={users} />
        <div className="ui stackable grid basic attached secondary segment">
          <div className="thirteen wide column">
            <IdeaSubmissionForm currentPresence={currentPresence} onIdeaSubmission={this.handleIdeaSubmission} showActionItem={showActionItem} />
          </div>
          <div className="three wide right aligned column">
            <SendActionItemsEmail retroChannel={this.props.retroChannel} />
            { this.props.isFacilitator && retroHasYetToProgressToActionItems &&
              <StageProgressionButton onProceedToActionItems={this.handleStageProgression} />
            }
          </div>
        </div>
        <DoorChime users={users} />
      </section>
    )
  }
}

Room.defaultProps = {
  isFacilitator: false,
}

Room.propTypes = {
  retroChannel: AppPropTypes.retroChannel.isRequired,
  users: AppPropTypes.users.isRequired,
  isFacilitator: React.PropTypes.bool,
}

export default Room
