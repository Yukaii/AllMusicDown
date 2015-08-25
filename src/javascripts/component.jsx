import React from 'react';
import $ from 'jquery'

var Album = React.createClass({
  render: function() {
    return(
      <div className="album">
        {this.props.album.title}
        <img src={this.props.album.cover_img} />
      </div>
    );
  }
})

export default class AlbumCollection extends React.Component {

  // 竟然不是 implement getInitialState e04
  constructor(props) {
    super(props);
    this.state = { albumList: [] };
  }

  componentDidMount() {
    $.ajax({
      url: '/entries',
      success: (data) => {
        this.setState({
          albumList: JSON.parse(data)
        });
      }
    })
  }

  render() {

    var albumNodes = this.state.albumList.map( (album) => {
      return(
        <Album album={album} />
      )
    });

    return(
      <div>
        { albumNodes }
      </div>
    );
  }
}
