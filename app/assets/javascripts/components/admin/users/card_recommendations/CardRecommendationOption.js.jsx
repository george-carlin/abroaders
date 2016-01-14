var CardRecommendationOption = React.createClass({
  render() {
    return (
      <tr onClick={this.props.clickHandler}>
        <td><input type="radio" name="card_account_card_id" /></td>
        <td>{this.props.card.identifier}</td>
        <td>{this.props.card.name}</td>
        <td>{this.props.card.bp.capitalize()}</td>
        <td>{this.props.card.brand.capitalize()}</td>
        <td>{this.props.card.type.capitalize()}</td>
      </tr>
    )
  }
});
