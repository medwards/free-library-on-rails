function addTag(tag) {
	if(tag == "")
		return;

	var selTags = selectedTags();
	if(selTags.indexOf(tag) > -1)
		// we've already selected that tag
		return;

	selTags.push(tag);

	$("tags").setValue(selTags.join(","));

	listTag(tag);
}

function removeTag(tag) {
	var removed = selectedTags().without(tag).join(",");

	$("tags").setValue(removed);
}

function selectedTags() {
	return $("tags").getValue().split(",").reject(function(t) { return t.empty();});
}

function listTag(tag) {
	var removeTagEl = new Element("span", { 'class': 'remove-tag' }).update("×");

	var li = new Element("li").update(removeTagEl);

	removeTagEl.observe('click', function() {
		removeTag(tag);
		li.remove();
	});

	li.insert(tag);

	$("tagList").insert(li);
}

Event.observe(window, 'load', function() {
	$("tags").hide();

	var tagList = new Element("ul", { 'id': 'tagList' });

	var newTag = new Element("input");
	var addTagEl = new Element("span", { 'class': 'add-tag' }).update("+");

	$("tags").up().insert(newTag);
	$("tags").up().insert(addTagEl);
	$("tags").up().insert(tagList);

	addTagEl.observe('click', function() {
		addTag($(newTag).getValue());
		$(newTag).clear();
	});

	var selTags = selectedTags();
	for(var i = 0; i < selTags.length; i++) {
		listTag(selTags[i]);
	}
});
