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
  const viewButtons = document.querySelectorAll('.stackedit-view-button, .markdown-preview-button');
  
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
            // Instead of using the StackEdit API, we'll create our own preview-only solution
            // Create a modal container
            const modalContainer = document.createElement('div');
            modalContainer.className = 'markdown-preview-modal';
            modalContainer.style.position = 'fixed';
            modalContainer.style.top = '0';
            modalContainer.style.left = '0';
            modalContainer.style.width = '100%';
            modalContainer.style.height = '100%';
            modalContainer.style.backgroundColor = 'rgba(0, 0, 0, 0.75)';
            modalContainer.style.zIndex = '9999';
            modalContainer.style.display = 'flex';
            modalContainer.style.justifyContent = 'center';
            modalContainer.style.alignItems = 'center';
            
            // Create the preview container
            const previewContainer = document.createElement('div');
            previewContainer.className = 'markdown-preview-content';
            previewContainer.style.width = '90%';
            previewContainer.style.maxWidth = '900px';
            previewContainer.style.height = '90%';
            previewContainer.style.maxHeight = '800px';
            previewContainer.style.backgroundColor = 'white';
            previewContainer.style.borderRadius = '8px';
            previewContainer.style.boxShadow = '0 4px 20px rgba(0, 0, 0, 0.3)';
            previewContainer.style.overflow = 'hidden';
            previewContainer.style.display = 'flex';
            previewContainer.style.flexDirection = 'column';
            
            // Create header with close button
            const header = document.createElement('div');
            header.style.padding = '12px 16px';
            header.style.borderBottom = '1px solid #eaeaea';
            header.style.display = 'flex';
            header.style.justifyContent = 'space-between';
            header.style.alignItems = 'center';
            
            const title = document.createElement('h3');
            title.textContent = 'Markdown Preview';
            title.style.margin = '0';
            title.style.fontSize = '1.2rem';
            title.style.color = '#333';
            
            const closeButton = document.createElement('button');
            closeButton.innerHTML = '&times;';
            closeButton.style.background = 'none';
            closeButton.style.border = 'none';
            closeButton.style.fontSize = '1.5rem';
            closeButton.style.cursor = 'pointer';
            closeButton.style.color = '#666';
            closeButton.style.padding = '0 8px';
            
            header.appendChild(title);
            header.appendChild(closeButton);
            
            // Create content area
            const content = document.createElement('div');
            content.style.padding = '20px';
            content.style.overflow = 'auto';
            content.style.flex = '1';
            
            // Load the markdown-it library if not already loaded
            if (!window.markdownit) {
              const script = document.createElement('script');
              script.src = 'https://cdn.jsdelivr.net/npm/markdown-it@13.0.1/dist/markdown-it.min.js';
              document.head.appendChild(script);
              
              script.onload = function() {
                renderMarkdown();
              };
            } else {
              renderMarkdown();
            }
            
            function renderMarkdown() {
              const md = window.markdownit({
                html: true,
                linkify: true,
                typographer: true
              });
              
              content.innerHTML = md.render(markdownContent);
              
              // Add some basic styling for the rendered markdown
              const style = document.createElement('style');
              style.textContent = `
                .markdown-preview-content h1, .markdown-preview-content h2 { border-bottom: 1px solid #eaecef; padding-bottom: 0.3em; }
                .markdown-preview-content pre { background-color: #f6f8fa; padding: 16px; border-radius: 6px; overflow: auto; }
                .markdown-preview-content code { background-color: rgba(27,31,35,0.05); padding: 0.2em 0.4em; border-radius: 3px; }
                .markdown-preview-content blockquote { padding: 0 1em; color: #6a737d; border-left: 0.25em solid #dfe2e5; }
                .markdown-preview-content img { max-width: 100%; }
                .markdown-preview-content table { border-collapse: collapse; width: 100%; overflow: auto; }
                .markdown-preview-content table th, .markdown-preview-content table td { border: 1px solid #dfe2e5; padding: 6px 13px; }
                .markdown-preview-content table tr { background-color: #fff; border-top: 1px solid #c6cbd1; }
                .markdown-preview-content table tr:nth-child(2n) { background-color: #f6f8fa; }
              `;
              document.head.appendChild(style);
            }
            
            // Assemble the modal
            previewContainer.appendChild(header);
            previewContainer.appendChild(content);
            modalContainer.appendChild(previewContainer);
            document.body.appendChild(modalContainer);
            
            // Handle close button click
            closeButton.addEventListener('click', function() {
              document.body.removeChild(modalContainer);
            });
            
            // Close when clicking outside the preview container
            modalContainer.addEventListener('click', function(event) {
              if (event.target === modalContainer) {
                document.body.removeChild(modalContainer);
              }
            });
            
            // Close on escape key
            document.addEventListener('keydown', function(event) {
              if (event.key === 'Escape' && document.body.contains(modalContainer)) {
                document.body.removeChild(modalContainer);
              }
            });
            
          } catch (error) {
            console.error('Error creating markdown preview:', error);
            alert('There was an error displaying the markdown preview. Please try again.');
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
