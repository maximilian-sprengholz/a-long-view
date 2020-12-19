<script>
// This script adds lightbox functionality to the figures created in the .md -> html flow
// Depends on the proper CSS
// Author: Maximilian Sprengholz

var Img_Grid_Lightbox = new function() {
    // check if organized in grids or not
    let allGrids = document.querySelectorAll('.figure,.subfigures');
    if (allGrids.length == 0) {
        // console.log(allGrids.length);
        allGrids = document.getElementsByTagName('body');
    }
    let lightbox = false;
    let imgIndex = [
        src = [],
        cap = []
    ];
    // lightbox functionality
    this.startLightbox = function(element) {
        // start lightbox and set image source
        let gridId = Number(element.getAttribute("gridId"));
        let imgId  = Number(element.getAttribute("imgId"));
        const imgNo = imgIndex[0][gridId].length;
        document.getElementById('lightbox-img-scaler').style.backgroundImage = 'url(' + imgIndex[0][gridId][imgId] + ')';
        document.getElementById('lightbox-legend').innerHTML = '<span>' + (imgId+1) + '/' + imgNo + '</span><span>' + imgIndex[1][gridId][imgId] + '</span>';
        document.getElementById('lightbox-container').style.display = 'flex';
        // set click events for navigation
        document.getElementById('lightbox-prev').addEventListener("click",function(){
            if (imgId > 0) {
                imgId--
            } else {
                imgId = (imgNo - 1)
            }
            document.getElementById('lightbox-img-scaler').style.backgroundImage = 'url(' + imgIndex[0][gridId][imgId] + ')';
            document.getElementById('lightbox-legend').innerHTML = '<span>' + (imgId+1) + '/' + imgNo + '</span><span>' + imgIndex[1][gridId][imgId] + '</span>';
        });
        document.getElementById('lightbox-next').addEventListener("click",function(){
            if (imgId < (imgNo - 1)) {
                imgId++
            } else {
                imgId = 0
            }
            document.getElementById('lightbox-img-scaler').style.backgroundImage = 'url(' + imgIndex[0][gridId][imgId] + ')';
            document.getElementById('lightbox-legend').innerHTML = '<span>' + (imgId+1) + '/' + imgNo + '</span><span>' + imgIndex[1][gridId][imgId] + '</span>';
        });
        // close events per click and ESC
        document.getElementById('lightbox-close').addEventListener("click",function(){
            document.getElementById('lightbox-container').style.display = 'none';
            document.body.removeEventListener("keyup", keyDown);
        });
        keyDown = function(){
            let keyCode = event.which;
            if (keyCode == 27) {
                document.getElementById('lightbox-container').style.display = 'none';
                document.body.removeEventListener("keyup", keyDown);
            };
        };
        document.body.addEventListener("keyup", keyDown);
    };
    // initialize
    this.init = function() {
        // for all image grids in document
        for (let i=0; i<allGrids.length; i++) {
            // console.log('Graph grid: ' + i)
            // placeholder arrays per grid (sources and caps)
            let imgSrc = [];
            let imgCap = [];
            // index all images within grid
            const allImg = allGrids[i].querySelectorAll('img');
            // for all images within a single grid
            for (let j=0; j<allImg.length; j++) {
                // console.log('Image within grid: ' + j);
                // get and push source and figcaption in array
                imgSrc.push(allImg[j].getAttribute('src'));
                let cap = allGrids[i].querySelectorAll('img[id="' + allImg[j].getAttribute('id') + '"]' + ' + figcaption')[0];
                if (cap) {
                    imgCap.push(cap.innerHTML);
                } else {
                    imgCap.push('');
                }
                // set attributes that will be fed to lightbox to get sources
                allImg[j].setAttribute("gridId", i );
                allImg[j].setAttribute("imgId", j );
                // add click event listener to open lightbox
                allImg[j].addEventListener("click", function(){ Img_Grid_Lightbox.startLightbox(allImg[j]); });
            };
            // push grid specific arrays in main index
            imgIndex[0].push(imgSrc);
            imgIndex[1].push(imgCap);
        };
        // append lightbox container once (after pushing all images in Index)
        let lightboxContainer = '<div id="lightbox-container">\n'
        lightboxContainer += '<a href="#/" id="lightbox-prev">&#9664;</a>\n'
        lightboxContainer += '<a href="#/" id="lightbox-next">&#9654;</a>\n'
        lightboxContainer += '<a href="#/" id="lightbox-close">&times;</a>\n'
        lightboxContainer += '<div id="lightbox-img-scaler"></div>\n'
        lightboxContainer += '<p id="lightbox-legend"></p>\n'
        lightboxContainer += '</div>\n'
        document.body.insertAdjacentHTML('afterbegin', lightboxContainer)
    };
};

// Init on load
window.addEventListener("load", function(){
    Img_Grid_Lightbox.init();
});

</script>
