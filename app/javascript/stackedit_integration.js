// StackEdit integration for blog content
document.addEventListener('turbo:load', function() {
  initStackEdit();
});

document.addEventListener('DOMContentLoaded', function() {
  initStackEdit();
});

function initStackEdit() {
  console.log('Initializing StackEdit integration');
  
  // Setup for editor mode (new/edit blog post)
  setupEditorMode();
  
  // Setup for viewer mode (show blog post)
  setupViewerMode();
}

function setupEditorMode() {
  const contentTextarea = document.getElementById('blog_post_content');
  const openStackEditButton = document.getElementById('open_stackedit');
  
  if (contentTextarea && openStackEditButton) {
    console.log('Found textarea and button, setting up editor mode');
    openStackEditButton.addEventListener('click', function(e) {
      e.preventDefault();
      console.log('StackEdit editor button clicked');
      
      try {
        // Initialize the StackEdit instance
        const stackedit = new Stackedit();
        console.log('StackEdit initialized');
        
        // Open the iframe with the current content
        stackedit.openFile({
          content: {
            text: contentTextarea.value
          }
        });
        console.log('StackEdit opened with content');
        
        // Listen to StackEdit events and update the textarea content when needed
        stackedit.on('fileChange', (file) => {
          console.log('File changed in StackEdit, updating textarea');
          contentTextarea.value = file.content.text;
        });
      } catch (error) {
        console.error('Error initializing StackEdit editor:', error);
        alert('There was an error opening StackEdit. Please make sure you have an internet connection and try again.');
      }
    });
  } else {
    console.log('Editor mode elements not found', { 
      contentTextarea: contentTextarea ? 'found' : 'not found', 
      openStackEditButton: openStackEditButton ? 'found' : 'not found' 
    });
  }
}

function setupViewerMode() {
  // Find all view buttons
  const viewButtons = document.querySelectorAll('.stackedit-view-button');
  
  if (viewButtons.length > 0) {
    console.log(`Found ${viewButtons.length} view buttons, setting up viewer mode`);
    
    viewButtons.forEach(button => {
      button.addEventListener('click', function(e) {
        e.preventDefault();
        
        // Get the content ID from the data attribute
        const contentId = this.getAttribute('data-content-id');
        const contentElement = document.getElementById(contentId);
        
        if (contentElement) {
          const markdownContent = contentElement.textContent.trim();
          console.log('Opening StackEdit viewer with content from', contentId);
          
          try {
            // Initialize StackEdit
            const stackedit = new Stackedit();
            
            // Open the content in viewer mode
            stackedit.openFile({
              content: {
                text: markdownContent
              },
              viewMode: 'view' // This sets StackEdit to view mode
            });
          } catch (error) {
            console.error('Error initializing StackEdit viewer:', error);
            alert('There was an error opening StackEdit. Please make sure you have an internet connection and try again.');
          }
        } else {
          console.error(`Content element with ID ${contentId} not found`);
        }
      });
    });
  } else {
    console.log('No view buttons found on this page');
  }
}
