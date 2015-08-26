import React from 'react';

import $ from 'jquery'
import _ from 'underscore'

import polyfill from 'es6-promise';
import 'isomorphic-fetch';

var Album = React.createClass({
  render: function() {
    var album = this.props.album;

    var summaryStyle = {
      whiteSpace: 'pre-wrap'
    }

    return(
      <div className="album">
        <img src={ album.cover_img } />
        <h3>{ album.title }</h3>
        <div className="album-summary" style={summaryStyle}>
          { album.summary }
        </div>
        <ul>
          { _.values(album.direct_links).map((link) => {
              return(
                <li>
                  <a href={ link }>{ link }</a>
                </li>
              )
            })
          }
        </ul>
      </div>
    );
  }
})

export default class AlbumCollection extends React.Component {
  // 竟然不是 implement getInitialState e04
  constructor(props) {
    super(props);
    this.state = { albumList: props.initialList };
  }

  componentDidMount() {
    fetch('/entries').then((response) => {
      return response.json();
    }).then((albumList) => {
      this.setState({albumList: albumList});
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
// AlbumCollection.propTypes = {  };
AlbumCollection.defaultProps = { initialList: [] };
