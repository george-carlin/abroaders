var CardRecommendationOption = React.createClass({

  propTypes: {
    card:         React.PropTypes.object.isRequired,
    clickHandler: React.PropTypes.func.isRequired
  },

  render() {
    return (
      <tr onClick={this.props.clickHandler}>
        <td>
          <input
            id={`card_account_card_id_${this.props.card.id}`}
            type="radio"
            name="card_account_card_id"
          />
        </td>
        <td>{this.props.card.attributes.identifier}</td>
        <td>{this.props.card.attributes.name}</td>
        <td>{this.props.card.attributes.bank_name}</td>
        <td>{this.props.card.attributes.bp.capitalize()}</td>
        <td>{this.props.card.attributes.brand.capitalize()}</td>
        <td>{this.props.card.attributes.type.capitalize()}</td>
      </tr>
    )
  }
});
